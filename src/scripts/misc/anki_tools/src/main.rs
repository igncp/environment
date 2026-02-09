use crate::{
    anki_connect_client::AnkiConnectClient,
    logs::setup_logs,
    models::{Deck, ModelsClients},
    open_ai_client::OpenAiClient,
};
use clap::{Parser, Subcommand};

mod anki_connect_client;
mod constants;
mod jyutping_reader;
mod logs;
mod models;
mod open_ai_client;

fn handle_error(error: impl std::fmt::Display) -> ! {
    eprintln!("錯誤：{}", error);
    std::process::exit(1);
}

macro_rules! unwrap_or_exit {
    ($result:expr) => {
        match $result {
            Ok(val) => val,
            Err(e) => handle_error(e),
        }
    };
}

#[derive(Parser)]
#[command(name = "anki_tools")]
#[command(about = "Anki 工具", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// 列出所有可用嘅牌組
    ListDecks,
    /// 處理缺少語法類型嘅筆記
    ProcessIncompleteFields {
        /// 牌組名稱
        deck_name: String,
        /// 自動確認所有操作（唔會提示確認）
        #[arg(short = 'y', long = "yes")]
        yes: bool,
    },
    /// 為筆記加入顏色（按粵拼聲調）
    AddColors {
        /// 牌組名稱
        deck_name: String,
    },
    /// 為缺少粵拼嘅筆記填入粵拼
    FillJyutping {
        /// 牌組名稱
        deck_name: String,
    },
}

#[tokio::main]
async fn main() {
    dotenvy::dotenv().ok();

    let cli = Cli::parse();

    let anki_client = AnkiConnectClient::new();
    let open_ai_client = OpenAiClient::new();
    let models_clients = ModelsClients {
        anki_client,
        open_ai_client,
    };

    setup_logs();

    match cli.command {
        Commands::ListDecks => {
            let deck_names = unwrap_or_exit!(models_clients.anki_client.get_deck_names().await);
            println!("可用嘅牌組：");
            for name in deck_names.result {
                println!("- {}", name);
            }
        }
        Commands::ProcessIncompleteFields { deck_name, yes } => {
            let mut deck = unwrap_or_exit!(Deck::get_from_name(&models_clients, &deck_name).await);
            unwrap_or_exit!(deck.process_incomplete_notes_generic(yes).await);
        }
        Commands::AddColors { deck_name } => {
            let mut deck = unwrap_or_exit!(Deck::get_from_name(&models_clients, &deck_name).await);
            unwrap_or_exit!(deck.add_colors().await);
        }
        Commands::FillJyutping { deck_name } => {
            let mut deck = unwrap_or_exit!(Deck::get_from_name(&models_clients, &deck_name).await);
            unwrap_or_exit!(deck.fill_jyutping().await);
        }
    }
}
