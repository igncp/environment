use clap::{Parser, Subcommand};
use dotenv::dotenv;
use futures::TryStreamExt;
use reqwest::{Client, Url};
use serde::Deserialize;
use std::io;
use std::{env, error::Error};
use time::{self, UtcOffset};
use tokio::net::TcpStream;
use tracing::Level;
use tracing::debug;
use tracing_appender::non_blocking::WorkerGuard;
use tracing_appender::rolling::{self};
use tracing_subscriber::{filter, fmt, prelude::*};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand, Debug)]
enum Commands {
    Email,
}

#[tokio::main]
async fn main() {
    dotenv().ok();
    let _log_guard = setup_logs();

    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Email) => {
            run_imap().await.unwrap();
        }
        None => {
            println!("No specific command provided.");
        }
    }
}

struct GmailOAuth2 {
    user: String,
    access_token: String,
}

impl async_imap::Authenticator for &GmailOAuth2 {
    type Response = String;

    fn process(&mut self, _data: &[u8]) -> Self::Response {
        format!(
            "user={}\x01auth=Bearer {}\x01\x01",
            self.user, self.access_token
        )
    }
}

async fn run_imap() -> Result<(), String> {
    let imap_server = "imap.gmail.com";
    let login = "icarbajop@gmail.com";
    let password = std::env::var("GMAIL_APP_PASSWORD").expect("GMAIL_APP_PASSWORD must be set");
    let imap_addr = (imap_server, 993);
    let tcp_stream = TcpStream::connect(imap_addr)
        .await
        .map_err(|e| e.to_string())?;
    let tls = async_native_tls::TlsConnector::new();
    let tls_stream = tls
        .connect(imap_server, tcp_stream)
        .await
        .map_err(|e| e.to_string())?;

    let client = async_imap::Client::new(tls_stream);
    debug!("-- connected to {}:{}", imap_addr.0, imap_addr.1);

    let mut imap_session = client
        .login(login, password)
        .await
        .map_err(|e| e.0.to_string())?;
    debug!("-- logged in a {}", login);

    let mailbox = imap_session
        .select("INBOX")
        .await
        .map_err(|e| e.to_string())?;
    debug!("-- INBOX selected");

    let total_messages = mailbox.exists;

    // fetch message number 1 in this mailbox, along with its RFC822 field.
    // RFC 822 dictates the format of the body of e-mails
    let messages_stream = imap_session
        .fetch(&total_messages.to_string(), "RFC822")
        .await
        .map_err(|e| e.to_string())?;

    let messages: Vec<_> = messages_stream
        .try_collect()
        .await
        .map_err(|e| e.to_string())?;

    let message = if let Some(m) = messages.first() {
        m
    } else {
        return Ok(());
    };

    let body = message.body().expect("message did not have a body!");
    let body = std::str::from_utf8(body)
        .expect("message was not valid utf-8")
        .to_string();
    debug!("-- 1 message received, logging out");
    debug!("body {:?}", body);

    let summary = summarise_email(&body).await.map_err(|e| e.to_string())?;
    println!("Summary: {}", summary);
    debug!("summary {:?}", summary);

    imap_session.logout().await.map_err(|e| e.to_string())?;

    Ok(())
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

async fn summarise_email(text: &str) -> Result<String, Box<dyn Error>> {
    let client = Client::new();
    let url = Url::parse("https://api.openai.com/v1/chat/completions").unwrap();

    let mut prompt = [
        "Summarize the email below in English.",
        "Try to find any unsubscribe links in the email and include them in the summary.",
        "Also try to find marketing options handling links.",
        "Make sure you don't have any typo in the shared links.",
    ]
    .join("\n");

    let total_chars = text.chars().count();
    let mut parsed_text = text.to_string();

    let max_chars = 200_000;

    if total_chars > max_chars {
        parsed_text = parsed_text.chars().take(max_chars).collect();
    }

    if prompt.len() > max_chars {
        prompt = prompt[..max_chars].to_string();
    }

    let body = serde_json::json!({
        "model": "gpt-4.1-nano",
        "messages": [{
            "role": "system",
            "content": prompt
        }, {
            "role": "user",
            "content": parsed_text
        }],
        "max_completion_tokens": 1_000
    });

    debug!("body {:?}", body);

    let mut headers_map = reqwest::header::HeaderMap::new();
    let api_key = env::var("OPENAI_API")?;

    headers_map.insert(
        "Content-Type",
        reqwest::header::HeaderValue::from_static("application/json"),
    );
    headers_map.insert(
        "Authorization",
        reqwest::header::HeaderValue::from_str(&format!("Bearer {api_key}"))?,
    );

    let response = client
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

fn setup_logs() -> WorkerGuard {
    let logger_level = std::env::var("LOG_LEVEL").unwrap_or("".to_string());

    let logger_level = match logger_level.as_str() {
        "trace" => Level::TRACE,
        "debug" => Level::DEBUG,
        "warn" => Level::WARN,
        "info" => Level::INFO,
        "error" => Level::ERROR,
        _ => Level::INFO,
    };

    let file_appender = rolling::daily("/tmp/ai_agent", "log");
    let (non_blocking_appender, log_guard) = tracing_appender::non_blocking(file_appender);
    let local_offset = UtcOffset::current_local_offset().unwrap_or(UtcOffset::UTC);
    let local_timer =
        fmt::time::OffsetTime::new(local_offset, time::format_description::well_known::Rfc3339);

    let subscriber = tracing_subscriber::registry()
        .with(
            fmt::layer()
                .with_writer(non_blocking_appender)
                .with_ansi(false)
                .with_timer(local_timer.clone())
                .with_filter(filter::LevelFilter::from_level(Level::DEBUG)),
        )
        .with(
            fmt::layer()
                .with_writer(io::stdout)
                .with_timer(local_timer)
                .with_filter(filter::LevelFilter::from_level(logger_level)),
        );

    tracing::subscriber::set_global_default(subscriber).unwrap();

    debug!("logger_level (from the environment) {logger_level:?}");
    debug!("logger_level {logger_level:?}");

    return log_guard;
}
