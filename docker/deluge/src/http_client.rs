use std::{collections::HashMap, process};

use reqwest::{Client, RequestBuilder};
use serde::{de::DeserializeOwned, Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize, Clone)]
#[serde(untagged)]
enum Host {
    String(String),
    Number(u32),
}

type Hosts = Vec<Vec<Host>>;

#[derive(Debug, Deserialize, Clone)]
#[allow(dead_code)]
pub struct ResponseError {
    pub message: String,
}

#[derive(Debug, Deserialize, Clone)]
pub struct DelugeResponse<Data> {
    pub result: Data,
    pub error: Option<ResponseError>,
}

#[derive(Debug, Serialize)]
struct DelugeRequest<Params> {
    id: u32,
    method: String,
    params: Params,
}

#[derive(Debug, Deserialize, Clone)]
#[allow(dead_code)]
struct Stats {
    max_num_connections: u32,
}

#[derive(Debug, Deserialize, Clone)]
#[allow(dead_code)]
pub struct Torrent {
    pub name: String,
    pub progress: f32,
}

#[derive(Debug, Deserialize, Clone)]
#[allow(dead_code)]
pub struct UpdateUI {
    connected: bool,
    stats: Stats,
    pub torrents: HashMap<String, Torrent>,
}

impl<Params> DelugeRequest<Params>
where
    Params: Serialize,
{
    fn new(id: u32, method: &str, params: Params) -> Self {
        Self {
            id,
            method: method.to_string(),
            params,
        }
    }

    fn serialize(&self) -> String {
        serde_json::to_string(self).unwrap()
    }
}

pub struct DelugeHttpClient {
    client: Client,
    cookie: Option<String>,
    req_id: u32,
}

impl DelugeHttpClient {
    pub fn new() -> Self {
        let client = Client::new();

        Self {
            client,
            cookie: None,
            req_id: 0,
        }
    }

    fn generate_req_id(&mut self) -> u32 {
        self.req_id += 1;

        self.req_id
    }

    fn get_common_req(&self) -> RequestBuilder {
        let mut res = self
            .client
            .post("http://localhost:8112/json")
            .header("Content-Type", "application/json")
            .header("Accept", "application/json");

        if let Some(cookie) = &self.cookie {
            res = res.header("Cookie", cookie)
        }

        res
    }

    async fn login(&mut self) {
        let req_body = DelugeRequest::new(self.generate_req_id(), "auth.login", vec!["deluge"]);

        let res = self
            .get_common_req()
            .body(req_body.serialize())
            .send()
            .await;

        if res.is_err() {
            println!("No connection to deluge daemon. Make sure docker is running, or run: `./deluge_custom_client run`");
            process::exit(1);
        }

        let res = res.unwrap();

        let session_cookie_str = res
            .headers()
            .get("set-cookie")
            .expect("Session cookie is missing")
            .to_str()
            .unwrap();

        self.cookie = Some(session_cookie_str.to_string());
    }

    async fn connect(&mut self) {
        self.login().await;

        let req_body = DelugeRequest::new(
            self.generate_req_id(),
            "web.get_hosts",
            vec![] as Vec<String>,
        );

        let res = self
            .get_common_req()
            .body(req_body.serialize())
            .send()
            .await
            .unwrap();

        let body = res.text().await.unwrap();

        let hosts_response = serde_json::from_str::<DelugeResponse<Hosts>>(&body).unwrap();

        let target_host = hosts_response.result[0][0].clone();

        let req_body = DelugeRequest::new(
            self.generate_req_id(),
            "web.connect",
            vec![match target_host {
                Host::String(s) => s,
                Host::Number(n) => n.to_string(),
            }],
        );

        self.get_common_req()
            .body(req_body.serialize())
            .send()
            .await
            .unwrap();
    }

    async fn common_rpc_request_raw<A: Serialize>(&mut self, cmd: &str, params: A) -> String {
        self.connect().await;

        let body_req = DelugeRequest::new(self.generate_req_id(), cmd, params);

        let res = self
            .get_common_req()
            .body(body_req.serialize())
            .send()
            .await
            .unwrap();

        res.text().await.unwrap()
    }

    async fn common_rpc_request<A: DeserializeOwned, B: Serialize>(
        &mut self,
        cmd: &str,
        params: B,
    ) -> DelugeResponse<A> {
        let response_text = self.common_rpc_request_raw(cmd, params).await;

        serde_json::from_str::<DelugeResponse<A>>(&response_text).unwrap()
    }

    pub async fn get_torrents(&mut self) -> UpdateUI {
        #[derive(Debug, Serialize, Clone)]
        #[serde(untagged)]
        enum TorrentsRequest<'a> {
            List(Vec<&'a str>),
            Object(HashMap<String, String>),
        }

        let params = vec![
            TorrentsRequest::List(vec![
                "name",
                "queue",
                "progress",
                "distributed_copies",
                "eta",
            ]),
            TorrentsRequest::Object(HashMap::new()),
        ];

        self.common_rpc_request("web.update_ui", params)
            .await
            .result
    }

    pub async fn remove_torrent(&mut self, torrent_id: String) -> bool {
        #[derive(Debug, Serialize, Clone)]
        #[serde(untagged)]
        enum RemoveTorrentRequest {
            Id(String),
            Data(bool),
        }

        let params = vec![
            RemoveTorrentRequest::Id(torrent_id),
            RemoveTorrentRequest::Data(false),
        ];

        let response = self
            .common_rpc_request::<Option<String>, _>("core.remove_torrent", params)
            .await;

        response.error.is_none()
    }

    pub async fn add_torrent(&mut self, magnet_link: String) -> bool {
        #[derive(Debug, Serialize, Clone)]
        #[serde(untagged)]
        enum AddTorrentRequest {
            Magnet(String),
            EmptyObject(HashMap<String, String>),
        }

        let params = vec![
            AddTorrentRequest::Magnet(magnet_link),
            AddTorrentRequest::EmptyObject(HashMap::new()),
        ];

        let response = self
            .common_rpc_request::<Option<String>, _>("core.add_torrent_magnet", params)
            .await;

        response.error.is_none()
    }

    pub async fn get_daemon_version(&mut self) -> String {
        self.common_rpc_request("daemon.get_version", Vec::<String>::new())
            .await
            .result
    }

    pub async fn get_daemon_method_list(&mut self) -> Vec<String> {
        self.common_rpc_request("daemon.get_method_list", Vec::<String>::new())
            .await
            .result
    }

    pub async fn get_config(&mut self) -> String {
        self.common_rpc_request_raw("core.get_config", Vec::<String>::new())
            .await
    }

    pub async fn get_external_ip(&mut self) -> String {
        self.common_rpc_request("core.get_external_ip", Vec::<String>::new())
            .await
            .result
    }
}
