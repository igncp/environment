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
mod utils;

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

fn get_deck_name(deck_name_arg: Option<String>) -> String {
    deck_name_arg
        .or_else(|| std::env::var("DEFAULT_DECK_NAME").ok())
        .unwrap_or_else(|| {
            eprintln!("錯誤：未提供牌組名稱且環境變數 DEFAULT_DECK_NAME 未設置");
            eprintln!("請提供牌組名稱或在 .env 文件中設置 DEFAULT_DECK_NAME");
            std::process::exit(1);
        })
}

#[derive(Parser)]
#[command(name = "anki_tools")]
#[command(about = "Anki 工具", long_about = None)]
#[command(
    help_template = "\n{about-with-newline}\n用法：{usage}\n\n命令：\n{subcommands}\n\n選項：\n  -h, --help  顯示幫助信息{after-help}",
    disable_help_subcommand = true
)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// 列出所有可用嘅牌組
    #[command(
        help_template = "\n{about-with-newline}\n用法：{usage}\n\n選項：\n  -h, --help  顯示幫助信息{after-help}"
    )]
    ListDecks,
    /// 分析牌組嘅統計資料
    #[command(
        help_template = "\n{about-with-newline}\n用法：{usage}\n\n參數：\n{positionals}\n\n選項：\n  -f, --inspect-fields  檢查欄位\n  -h, --help            顯示幫助信息{after-help}"
    )]
    AnalyzeDeck {
        /// 牌組名稱（如未提供則使用 DEFAULT_DECK_NAME 環境變數）
        #[arg(value_name = "牌組名稱")]
        deck_name: Option<String>,
        /// 檢查欄位，尋找傳統文字出現喺描述入面嘅筆記
        #[arg(short = 'f', long = "inspect-fields", help = "檢查欄位")]
        inspect_fields: bool,
    },
    /// 處理缺少語法類型嘅筆記
    #[command(
        help_template = "\n{about-with-newline}\n用法：{usage}\n\n參數：\n{positionals}\n\n選項：\n  -y, --yes   自動確認\n  -h, --help  顯示幫助信息{after-help}"
    )]
    ProcessIncompleteFields {
        /// 牌組名稱（如未提供則使用 DEFAULT_DECK_NAME 環境變數）
        #[arg(value_name = "牌組名稱")]
        deck_name: Option<String>,
        /// 自動確認所有操作（唔會提示確認）
        #[arg(short = 'y', long = "yes", help = "自動確認")]
        yes: bool,
    },
    /// 為筆記加入顏色（按粵拼聲調）
    #[command(
        help_template = "\n{about-with-newline}\n用法：{usage}\n\n參數：\n{positionals}\n\n選項：\n  -h, --help  顯示幫助信息{after-help}"
    )]
    AddColors {
        /// 牌組名稱（如未提供則使用 DEFAULT_DECK_NAME 環境變數）
        #[arg(value_name = "牌組名稱")]
        deck_name: Option<String>,
    },
    /// 為缺少粵拼嘅筆記填入粵拼
    #[command(
        help_template = "\n{about-with-newline}\n用法：{usage}\n\n參數：\n{positionals}\n\n選項：\n  -h, --help  顯示幫助信息{after-help}"
    )]
    FillJyutping {
        /// 牌組名稱（如未提供則使用 DEFAULT_DECK_NAME 環境變數）
        #[arg(value_name = "牌組名稱")]
        deck_name: Option<String>,
    },
    /// 導出牌組到本地文件
    #[command(
        help_template = "\n{about-with-newline}\n用法：{usage}\n\n參數：\n{positionals}\n\n選項：\n  -o, --output <路徑>  輸出文件路徑\n  -s, --schedule       包含學習進度\n  -h, --help           顯示幫助信息{after-help}"
    )]
    ExportDeck {
        /// 牌組名稱（如未提供則使用 DEFAULT_DECK_NAME 環境變數）
        #[arg(value_name = "牌組名稱")]
        deck_name: Option<String>,
        /// 輸出文件路徑（.apkg 格式）
        #[arg(short = 'o', long = "output", value_name = "路徑")]
        output: Option<String>,
        /// 包含學習進度（複習記錄、到期日期等）
        #[arg(short = 's', long = "schedule")]
        include_schedule: bool,
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
        Commands::AnalyzeDeck {
            deck_name,
            inspect_fields,
        } => {
            let deck_name = get_deck_name(deck_name);
            let deck = unwrap_or_exit!(Deck::get_from_name(&models_clients, &deck_name).await);
            println!("牌組分析：{}", deck_name);
            println!("筆記總數：{}", deck.notes_ids.len());
            println!("卡片總數：{}", deck.cards_ids.len());

            // 搵出重複嘅 Traditional 欄位
            println!("\n檢查重複嘅 Traditional 欄位...");
            deck.find_duplicate_traditional();

            if inspect_fields {
                println!();
                println!("檢查欄位...");
                let (trad_in_desc_ids, same_english_ids) = deck.inspect_fields();

                if !trad_in_desc_ids.is_empty() {
                    println!("\n係咪要更新呢啲筆記（傳統文字喺描述入面）？(y/N)");
                    println!("（將會用 AI 改進現有釋義，生成唔包含原文字嘅新釋義）");

                    let mut input = String::new();
                    if std::io::stdin().read_line(&mut input).is_ok() {
                        let trimmed = input.trim();
                        if trimmed.eq_ignore_ascii_case("y") {
                            unwrap_or_exit!(
                                deck.update_notes_with_ai_definitions(&trad_in_desc_ids)
                                    .await
                            );
                        } else {
                            println!("已取消更新");
                        }
                    }
                }

                if !same_english_ids.is_empty() {
                    println!(
                        "\n搵到 {} 個筆記嘅英文釋義同繁體/粵拼相同",
                        same_english_ids.len()
                    );
                    println!("\n係咪要用 AI 生成新嘅釋義？(y/N)");
                    println!("(將會根據繁體欄位生成不包含原文字嘅新釋義)");

                    let mut input = String::new();
                    if std::io::stdin().read_line(&mut input).is_ok() {
                        let trimmed = input.trim();
                        if trimmed.eq_ignore_ascii_case("y") {
                            unwrap_or_exit!(
                                deck.update_notes_with_ai_definitions(&same_english_ids)
                                    .await
                            );
                        } else {
                            println!("已取消更新");
                        }
                    }
                }
            }
        }
        Commands::ProcessIncompleteFields { deck_name, yes } => {
            let deck_name = get_deck_name(deck_name);
            let mut deck = unwrap_or_exit!(Deck::get_from_name(&models_clients, &deck_name).await);
            unwrap_or_exit!(deck.process_incomplete_notes_generic(yes).await);
        }
        Commands::AddColors { deck_name } => {
            let deck_name = get_deck_name(deck_name);
            let mut deck = unwrap_or_exit!(Deck::get_from_name(&models_clients, &deck_name).await);
            unwrap_or_exit!(deck.add_colors().await);
        }
        Commands::FillJyutping { deck_name } => {
            let deck_name = get_deck_name(deck_name);
            let mut deck = unwrap_or_exit!(Deck::get_from_name(&models_clients, &deck_name).await);
            unwrap_or_exit!(deck.fill_jyutping().await);
        }
        Commands::ExportDeck {
            deck_name,
            output,
            include_schedule,
        } => {
            let deck_name = get_deck_name(deck_name);
            // 如果冇指定輸出路徑，用當前目錄 + 牌組名稱
            let output_path =
                output.unwrap_or_else(|| format!("{}.apkg", deck_name.replace(' ', "_")));

            // 確保路徑係絕對路徑
            let abs_path = if output_path.starts_with('/') {
                output_path.clone()
            } else {
                let current_dir =
                    std::env::current_dir().unwrap_or_else(|_| std::path::PathBuf::from("."));
                current_dir.join(&output_path).to_string_lossy().to_string()
            };

            println!("正在導出牌組 '{}' 到 {}...", deck_name, abs_path);
            if include_schedule {
                println!("包含學習進度");
            }

            let result = unwrap_or_exit!(
                models_clients
                    .anki_client
                    .export_deck(&deck_name, &abs_path, include_schedule)
                    .await
            );

            if result.result {
                println!("✅ 導出成功：{}", abs_path);
            } else {
                eprintln!("❌ 導出失敗");
                std::process::exit(1);
            }
        }
    }
}
