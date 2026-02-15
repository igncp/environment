// 顏色處理測試

mod common;
use common::*;
use std::collections::HashMap;

#[cfg(test)]
mod color_processing_tests {
    use super::*;

    #[test]
    fn test_tone_to_color_mapping() {
        print_test_info("聲調到顏色嘅映射");

        let tone_colors = get_tone_colors();

        // 驗證所有聲調都有對應顏色
        assert_eq!(tone_colors.get(&1), Some(&"#c0c0c0")); // silver
        assert_eq!(tone_colors.get(&2), Some(&"#7ceb95")); // green
        assert_eq!(tone_colors.get(&3), Some(&"#fccff9")); // pink
        assert_eq!(tone_colors.get(&4), Some(&"#b9d5f4")); // blue
        assert_eq!(tone_colors.get(&5), Some(&"#ffb27a")); // orange
        assert_eq!(tone_colors.get(&6), Some(&"#b34df7")); // purple
        assert_eq!(tone_colors.get(&0), Some(&"#000000")); // background

        println!("✅ 聲調顏色映射測試通過");
    }

    #[test]
    fn test_extract_tone_from_jyutping() {
        print_test_info("從粵拼提取聲調");

        // 測試基本聲調提取
        assert_eq!(extract_tone("san4"), 4);
        assert_eq!(extract_tone("fu6"), 6);
        assert_eq!(extract_tone("hok6"), 6);
        assert_eq!(extract_tone("tin1"), 1);

        // 測試冇聲調
        assert_eq!(extract_tone("abc"), 0);
        assert_eq!(extract_tone(""), 0);

        println!("✅ 聲調提取測試通過");
    }

    #[test]
    fn test_is_han_character() {
        print_test_info("漢字檢測");

        // 漢字範圍 (0x4E00..=0x9FFF)
        assert!(is_han('天'));
        assert!(is_han('主'));
        assert!(is_han('教'));
        assert!(is_han('學'));
        assert!(is_han('校'));

        // 非漢字
        assert!(!is_han('a'));
        assert!(!is_han('A'));
        assert!(!is_han('1'));
        assert!(!is_han(' '));
        assert!(!is_han(','));

        println!("✅ 漢字檢測測試通過");
    }

    #[test]
    fn test_split_jyutping_syllables() {
        print_test_info("分割粵拼音節");

        let jyutping = "san4 fu6";
        let syllables = split_jyutping(jyutping);
        assert_eq!(syllables.len(), 2);
        assert_eq!(syllables[0], "san4");
        assert_eq!(syllables[1], "fu6");

        // 測試多個音節
        let jyutping = "tin1 zyu2 gaau3 san4 zik1 jan4 jyun4";
        let syllables = split_jyutping(jyutping);
        assert_eq!(syllables.len(), 7);

        // 測試包含非音節 token
        let jyutping = "san4 fu6 123 abc";
        let syllables = split_jyutping(jyutping);
        assert_eq!(syllables.len(), 2); // 只有 san4 同 fu6 係有效音節

        println!("✅ 粵拼分割測試通過");
    }

    #[test]
    fn test_generate_colored_html() {
        print_test_info("生成彩色 HTML");

        let text = "神父";
        let jyutping = "san4 fu6";
        let html = generate_colored_html(text, jyutping);

        // 驗證 HTML 包含 span 標籤
        assert!(html.contains("<span"));
        assert!(html.contains("style="));
        assert!(html.contains("color:"));

        // 驗證包含原始字
        assert!(html.contains("神"));
        assert!(html.contains("父"));

        // 驗證顏色代碼
        assert!(html.contains("#b9d5f4")); // 聲調 4 (blue)
        assert!(html.contains("#b34df7")); // 聲調 6 (purple)

        println!("✅ 彩色 HTML 生成測試通過");
    }

    #[test]
    fn test_generate_colored_html_with_punctuation() {
        print_test_info("生成彩色 HTML（含標點）");

        let text = "你好！";
        let jyutping = "nei5 hou2";
        let html = generate_colored_html(text, jyutping);

        // 驗證標點符號保留
        assert!(html.contains("！"));

        // 驗證漢字上色
        assert!(html.contains("你"));
        assert!(html.contains("好"));

        println!("✅ 帶標點符號嘅彩色 HTML 測試通過");
    }

    #[test]
    fn test_color_html_mismatch_count() {
        print_test_info("漢字同音節數量唔匹配");

        let text = "神父學校"; // 4 個漢字
        let jyutping = "san4 fu6"; // 只有 2 個音節

        let html = generate_colored_html(text, jyutping);

        // 如果數量唔匹配，應該返回 None 或者保持原樣
        assert!(html.is_empty() || html == text);

        println!("✅ 數量唔匹配處理測試通過");
    }
}

// 輔助函數（暫時實現，之後會移到 operations/colors.rs）
fn get_tone_colors() -> HashMap<u8, &'static str> {
    let mut colors = HashMap::new();
    colors.insert(1, "#c0c0c0"); // silver
    colors.insert(2, "#7ceb95"); // green
    colors.insert(3, "#fccff9"); // pink
    colors.insert(4, "#b9d5f4"); // blue
    colors.insert(5, "#ffb27a"); // orange
    colors.insert(6, "#b34df7"); // purple
    colors.insert(0, "#000000"); // background
    colors
}

fn extract_tone(syllable: &str) -> u8 {
    syllable
        .chars()
        .rev()
        .find_map(|c| {
            if c.is_ascii_digit() {
                c.to_digit(10).map(|d| d as u8)
            } else {
                None
            }
        })
        .unwrap_or(0)
}

fn is_han(c: char) -> bool {
    matches!(c as u32, 0x4E00..=0x9FFF)
}

fn split_jyutping(jyutping: &str) -> Vec<&str> {
    jyutping
        .split_whitespace()
        .filter(|tok| {
            let has_digit_end = tok
                .chars()
                .last()
                .map(|c| c.is_ascii_digit())
                .unwrap_or(false);
            let has_letter = tok.chars().any(|c| c.is_ascii_alphabetic());
            has_digit_end && has_letter
        })
        .collect()
}

fn generate_colored_html(text: &str, jyutping: &str) -> String {
    let syllables = split_jyutping(jyutping);
    let tone_colors = get_tone_colors();
    let han_count = text.chars().filter(|c| is_han(*c)).count();

    // 如果音節數量唔夠，返回空字串
    if syllables.len() < han_count {
        return String::new();
    }

    let mut html = String::new();
    let mut syllable_idx = 0;

    for ch in text.chars() {
        if is_han(ch) {
            let syllable = syllables[syllable_idx];
            syllable_idx += 1;
            let tone = extract_tone(syllable);
            let color = tone_colors.get(&tone).unwrap_or(&"#000000");
            html.push_str(&format!("<span style=\"color:{}\">{}</span>", color, ch));
        } else {
            // 非漢字直接保留
            html.push(ch);
        }
    }

    html
}

#[cfg(test)]
mod jyutping_processing_tests {
    use super::*;

    #[test]
    fn test_map_character_to_jyutping() {
        print_test_info("映射漢字到粵拼");

        // 創建模擬嘅粵拼字典
        let mut jyutping_map: HashMap<char, String> = HashMap::new();
        jyutping_map.insert('神', "san4".to_string());
        jyutping_map.insert('父', "fu6".to_string());
        jyutping_map.insert('學', "hok6".to_string());
        jyutping_map.insert('校', "haau6".to_string());

        // 測試單字映射
        assert_eq!(jyutping_map.get(&'神'), Some(&"san4".to_string()));
        assert_eq!(jyutping_map.get(&'父'), Some(&"fu6".to_string()));

        // 測試唔存在嘅字
        assert_eq!(jyutping_map.get(&'無'), None);

        println!("✅ 漢字到粵拼映射測試通過");
    }

    #[test]
    fn test_convert_text_to_jyutping() {
        print_test_info("轉換文字為粵拼");

        let mut jyutping_map: HashMap<char, String> = HashMap::new();
        jyutping_map.insert('神', "san4".to_string());
        jyutping_map.insert('父', "fu6".to_string());

        let text = "神父";
        let result = convert_to_jyutping(text, &jyutping_map);

        assert_eq!(result, "san4 fu6");

        println!("✅ 文字轉粵拼測試通過");
    }

    #[test]
    fn test_convert_with_punctuation() {
        print_test_info("轉換文字（含標點）");

        let mut jyutping_map: HashMap<char, String> = HashMap::new();
        jyutping_map.insert('你', "nei5".to_string());
        jyutping_map.insert('好', "hou2".to_string());

        let text = "你好！";
        let result = convert_to_jyutping(text, &jyutping_map);

        // 標點符號應該保留
        assert!(result.contains("！"));
        assert!(result.contains("nei5"));
        assert!(result.contains("hou2"));

        println!("✅ 含標點轉換測試通過");
    }
}

fn convert_to_jyutping(text: &str, jyutping_map: &HashMap<char, String>) -> String {
    let mut result = Vec::new();

    for ch in text.chars() {
        if let Some(jyutping) = jyutping_map.get(&ch) {
            result.push(jyutping.clone());
        } else {
            result.push(ch.to_string());
        }
    }

    result.join(" ")
}
