use std::collections::HashMap;

use reqwest::{Client, RequestBuilder};
use serde::{de::DeserializeOwned, Deserialize, Serialize};

use crate::base::AppErr;

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
pub struct Stats {
    download_rate: f64,
    max_num_connections: u32,
}

impl Stats {
    pub fn get_download_rate_mb(&self) -> f64 {
        (self.download_rate / 1024.0) / 1024.0
    }
}

#[derive(Debug, Deserialize, Clone)]
#[allow(dead_code)]
pub struct Torrent {
    pub eta: i32,
    pub name: String,
    pub progress: f32,
}

#[derive(Debug, Deserialize, Clone)]
#[allow(dead_code)]
pub struct UpdateUI {
    connected: bool,
    pub stats: Stats,
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

    async fn login(&mut self) -> Result<(), AppErr> {
        let req_body = DelugeRequest::new(self.generate_req_id(), "auth.login", vec!["deluge"]);

        let res = self
            .get_common_req()
            .body(req_body.serialize())
            .send()
            .await;

        if res.is_err() {
            return Err("No connection to deluge daemon. Make sure docker is running, or run: `./deluge_custom_client run`")?;
        }

        let res = res.unwrap();

        let session_cookie_str = res
            .headers()
            .get("set-cookie")
            .expect("Session cookie is missing")
            .to_str()
            .unwrap();

        self.cookie = Some(session_cookie_str.to_string());

        Ok(())
    }

    async fn connect(&mut self) -> Result<(), AppErr> {
        self.login().await?;

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
            .await?;

        Ok(())
    }

    async fn common_rpc_request_raw<A: Serialize>(
        &mut self,
        cmd: &str,
        params: A,
    ) -> Result<String, AppErr> {
        self.connect().await?;

        let body_req = DelugeRequest::new(self.generate_req_id(), cmd, params);

        let res = self
            .get_common_req()
            .body(body_req.serialize())
            .send()
            .await
            .unwrap();

        let text = res.text().await?;

        Ok(text)
    }

    async fn common_rpc_request<A: DeserializeOwned, B: Serialize>(
        &mut self,
        cmd: &str,
        params: B,
    ) -> Result<DelugeResponse<A>, AppErr> {
        let response_text = self.common_rpc_request_raw(cmd, params).await?;

        let result = serde_json::from_str::<DelugeResponse<A>>(&response_text)?;

        Ok(result)
    }

    pub async fn get_torrents(&mut self) -> Result<UpdateUI, AppErr> {
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

        let result = self
            .common_rpc_request("web.update_ui", params)
            .await?
            .result;

        Ok(result)
    }

    pub async fn remove_torrent(&mut self, torrent_id: String) -> Result<bool, AppErr> {
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
            .common_rpc_request::<Option<bool>, _>("core.remove_torrent", params)
            .await?;

        Ok(response.error.is_none())
    }

    pub async fn add_torrent(&mut self, magnet_link: String) -> Result<bool, AppErr> {
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
            .await?;

        Ok(response.error.is_none())
    }

    pub async fn get_daemon_version(&mut self) -> Result<String, AppErr> {
        let result = self
            .common_rpc_request("daemon.get_version", Vec::<String>::new())
            .await?
            .result;

        Ok(result)
    }

    pub async fn get_daemon_method_list(&mut self) -> Result<Vec<String>, AppErr> {
        let result = self
            .common_rpc_request("daemon.get_method_list", Vec::<String>::new())
            .await?
            .result;

        Ok(result)
    }

    pub async fn get_config(&mut self) -> Result<String, AppErr> {
        let result = self
            .common_rpc_request_raw("core.get_config", Vec::<String>::new())
            .await?;

        Ok(result)
    }

    pub async fn get_external_ip(&mut self) -> Result<String, AppErr> {
        let result = self
            .common_rpc_request("core.get_external_ip", Vec::<String>::new())
            .await?
            .result;

        Ok(result)
    }
}
