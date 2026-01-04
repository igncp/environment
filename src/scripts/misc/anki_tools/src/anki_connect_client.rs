// https://github.com/amikey/anki-connect/blob/master/AnkiConnect.py

#![allow(dead_code)]

use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::collections::HashMap;

pub struct AnkiConnectClient {
    client: reqwest::Client,
}

#[derive(Deserialize, Serialize, Debug)]
pub struct AnkiResponse<T> {
    pub result: T,
    pub error: Option<String>,
}

impl AnkiConnectClient {
    async fn query<T>(
        &self,
        action: &str,
        params: Option<serde_json::Value>,
    ) -> Result<AnkiResponse<T>, Box<dyn std::error::Error>>
    where
        T: for<'de> Deserialize<'de>,
    {
        let mut msg = json!({
            "action": action,
            "version": 6,
        });
        if let Some(p) = params {
            msg["params"] = p;
        }
        let response = self
            .client
            .post("http://localhost:8765")
            .json(&msg)
            .send()
            .await?
            .json::<AnkiResponse<T>>()
            .await?;

        Ok(response)
    }
}

pub type CommonResponse<T> = Result<AnkiResponse<T>, Box<dyn std::error::Error>>;
type DecksIds = HashMap<String, u64>;
type CardsIdsList = Vec<u64>;

impl AnkiConnectClient {
    pub fn new() -> Self {
        AnkiConnectClient {
            client: reqwest::Client::new(),
        }
    }

    pub async fn get_deck_names(&self) -> CommonResponse<Vec<String>> {
        self.query::<Vec<String>>("deckNames", None).await
    }

    pub async fn get_deck_names_and_ids(&self) -> CommonResponse<DecksIds> {
        self.query::<DecksIds>("deckNamesAndIds", None).await
    }

    pub async fn find_cards(&self, deck_name: &String) -> CommonResponse<CardsIdsList> {
        self.query::<CardsIdsList>(
            "findCards",
            Some(json!({
                "query": format!(r#"deck:"{deck_name}""#)
            })),
        )
        .await
    }

    pub async fn find_notes(&self, deck_name: &String) -> CommonResponse<CardsIdsList> {
        self.query::<CardsIdsList>(
            "findNotes",
            Some(json!({
                "query": format!(r#"deck:"{deck_name}""#)
            })),
        )
        .await
    }

    pub async fn get_cards_info(&self, card_ids: &Vec<u64>) -> CommonResponse<Value> {
        self.query::<Value>(
            "cardsInfo",
            Some(json!({
                "cards": card_ids
            })),
        )
        .await
    }

    pub async fn get_notes_info(&self, notes_ids: &Vec<u64>) -> CommonResponse<Value> {
        self.query::<Value>(
            "notesInfo",
            Some(json!({
                "notes": notes_ids
            })),
        )
        .await
    }

    pub async fn get_deck_config(&self, deck_name: &str) -> CommonResponse<Value> {
        self.query::<Value>(
            "getDeckConfig",
            Some(json!({
                "deck": deck_name
            })),
        )
        .await
    }

    pub async fn gui_deck_overview(&self, deck_name: &str) -> CommonResponse<Value> {
        self.query::<Value>(
            "guiDeckOverview",
            Some(json!({
                "name": deck_name
            })),
        )
        .await
    }

    pub async fn update_note_fields(
        &self,
        note_id: u64,
        fields: HashMap<String, String>,
    ) -> CommonResponse<()> {
        self.query::<()>(
            "updateNoteFields",
            Some(json!({
                "note": {
                    "id": note_id,
                    "fields": fields
                }
            })),
        )
        .await
    }
}
