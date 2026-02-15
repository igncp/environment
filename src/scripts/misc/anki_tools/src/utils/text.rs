// 文字處理工具

use scraper::Html;

/// 正規化文字：轉換為小寫並移除標點符號
pub fn normalize_text(text: &str) -> String {
    text.to_lowercase()
        .chars()
        .filter(|c| c.is_alphanumeric() || c.is_whitespace())
        .collect::<String>()
        .split_whitespace()
        .collect::<Vec<_>>()
        .join(" ")
}

/// 從 HTML 提取純文字
#[allow(dead_code)]
pub fn extract_text_from_html(html: &str) -> String {
    Html::parse_fragment(html)
        .root_element()
        .text()
        .collect::<Vec<_>>()
        .join(" ")
        .trim()
        .to_string()
}

/// 檢查文字係咪包含指定字符集入面嘅任何字符
#[allow(dead_code)]
pub fn contains_any_char(text: &str, chars: &str) -> bool {
    text.chars().any(|c| chars.contains(c))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_normalize_text() {
        assert_eq!(normalize_text("Hello World"), "hello world");
        assert_eq!(normalize_text("Hello, World!"), "hello world");
        assert_eq!(normalize_text("Hello    World"), "hello world");
        assert_eq!(normalize_text(""), "");
        assert_eq!(normalize_text("   "), "");
    }

    #[test]
    fn test_extract_text_from_html() {
        assert_eq!(extract_text_from_html("<span>Hello</span>"), "Hello");
        assert_eq!(extract_text_from_html("Plain text"), "Plain text");
        assert_eq!(extract_text_from_html(""), "");
    }

    #[test]
    fn test_contains_any_char() {
        assert!(contains_any_char("神父", "神"));
        assert!(contains_any_char("神父", "父"));
        assert!(!contains_any_char("abc", "xyz"));
        assert!(contains_any_char("hello world", " "));
    }
}
