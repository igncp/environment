use std::env;

use reqwest::{Client, Url};
use serde::Deserialize;
use tracing::debug;

use crate::constants::ENV_OPENAI_API;

pub struct OpenAiClient {
    req_client: Client,
}

#[derive(Deserialize)]
struct CompletionMessage {
    content: String,
}

#[derive(Deserialize)]
struct CompletionChoice {
    message: CompletionMessage,
}

#[derive(Deserialize)]
struct CompletionResult {
    choices: Vec<CompletionChoice>,
}

impl OpenAiClient {
    pub fn new() -> Self {
        OpenAiClient {
            req_client: Client::new(),
        }
    }

    pub async fn get_prompt_response(
        &self,
        initial_prompt: &str,
    ) -> Result<String, Box<dyn std::error::Error>> {
        let url = Url::parse("https://api.openai.com/v1/chat/completions").unwrap();

        let total_chars = initial_prompt.chars().count();
        let mut parsed_text = initial_prompt.to_string();

        let max_chars = 200_000;

        if total_chars > max_chars {
            parsed_text = parsed_text.chars().take(max_chars).collect();
        }

        let mut prompt = initial_prompt.to_string();
        if prompt.len() > max_chars {
            prompt = prompt[..max_chars].to_string();
        }

        let body = serde_json::json!({
            "model": "gpt-5.2",
            "messages": [{
                "role": "system",
                "content": prompt
            }, {
                "role": "user",
                "content": parsed_text
            }],
            "max_completion_tokens": 1_000
        });

        let mut headers_map = reqwest::header::HeaderMap::new();
        let api_key = env::var(ENV_OPENAI_API)?;

        headers_map.insert(
            "Content-Type",
            reqwest::header::HeaderValue::from_static("application/json"),
        );
        headers_map.insert(
            "Authorization",
            reqwest::header::HeaderValue::from_str(&format!("Bearer {api_key}"))?,
        );

        let response = self
            .req_client
            .post(url)
            .headers(headers_map)
            .body(body.to_string())
            .send()
            .await?;

        if response.status().is_success() {
            let response_text = response.text().await?;
            let response_json: CompletionResult = serde_json::from_str(&response_text)?;

            debug!("response_text {:?}", response_text);

            Ok(response_json.choices[0].message.content.to_string())
        } else {
            let response_text = response.text().await?;
            debug!("Response: {}", response_text);
            let message = "An error occurred while trying to retrieve the translation.";
            Err(From::from(message))
        }
    }
}
