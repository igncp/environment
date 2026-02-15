// 常數定義
// Constants

/// 可能嘅語法類型列表
/// List of possible grammar types
pub const POSSIBLE_GRAMMAR_TYPES: &[&str] = &[
    "動詞 | 名詞",
    "名詞, 術語",
    "動詞",
    "名詞",
    "形容詞",
    "副詞",
    "語素",
    "術語",
    "反義",
    "韻母",
    "語句",
];

/// 聲調到顏色嘅映射
/// Tone to color mapping
#[allow(dead_code)]
pub fn get_tone_color(tone: u8) -> &'static str {
    match tone {
        1 => "#c0c0c0", // silver
        2 => "#7ceb95", // green
        3 => "#fccff9", // pink
        4 => "#b9d5f4", // blue
        5 => "#ffb27a", // orange
        6 => "#b34df7", // purple
        _ => "#000000", // background
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_tone_colors() {
        assert_eq!(get_tone_color(1), "#c0c0c0");
        assert_eq!(get_tone_color(2), "#7ceb95");
        assert_eq!(get_tone_color(3), "#fccff9");
        assert_eq!(get_tone_color(4), "#b9d5f4");
        assert_eq!(get_tone_color(5), "#ffb27a");
        assert_eq!(get_tone_color(6), "#b34df7");
        assert_eq!(get_tone_color(0), "#000000");
        assert_eq!(get_tone_color(99), "#000000");
    }

    #[test]
    fn test_grammar_types() {
        assert!(POSSIBLE_GRAMMAR_TYPES.contains(&"動詞"));
        assert!(POSSIBLE_GRAMMAR_TYPES.contains(&"名詞"));
        assert!(!POSSIBLE_GRAMMAR_TYPES.contains(&"未知類型"));
        assert_eq!(POSSIBLE_GRAMMAR_TYPES.len(), 11);
    }
}
