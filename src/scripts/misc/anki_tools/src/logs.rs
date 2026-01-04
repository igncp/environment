use tracing::Level;
use tracing_subscriber::FmtSubscriber;

use crate::constants::ENV_LOG_LEVEL;

pub fn setup_logs() {
    let logger_level = std::env::var(ENV_LOG_LEVEL).unwrap_or_default();

    let logger_level = match logger_level.as_str() {
        "trace" => Level::TRACE,
        "debug" => Level::DEBUG,
        "warn" => Level::WARN,
        "info" => Level::INFO,
        "error" => Level::ERROR,
        _ => Level::INFO,
    };

    let subscriber = FmtSubscriber::builder()
        .with_max_level(logger_level)
        .with_writer(std::io::stdout)
        .finish();

    tracing::subscriber::set_global_default(subscriber).expect("設置全局日誌訂閱器失敗");
}
