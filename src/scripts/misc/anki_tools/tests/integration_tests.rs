// 測試 Deck 基本操作

use serde_json::json;
use std::collections::HashMap;

mod common;
use common::*;

#[cfg(test)]
mod deck_operations_tests {
    use super::*;

    #[test]
    fn test_normalize_text() {
        print_test_info("文字正規化");

        // 測試小寫轉換
        let result = normalize_text("Hello World");
        assert_eq!(result, "hello world");

        // 測試移除標點符號
        let result = normalize_text("Hello, World!");
        assert_eq!(result, "hello world");

        // 測試移除多餘空格
        let result = normalize_text("Hello    World");
        assert_eq!(result, "hello world");

        // 測試混合情況
        let result = normalize_text("Clergy member in Catholicism, also known as 'priest'");
        assert_eq!(result, "clergy member in catholicism also known as priest");

        println!("✅ 文字正規化測試通過");
    }

    #[test]
    fn test_normalize_text_empty() {
        print_test_info("空字串正規化");

        let result = normalize_text("");
        assert_eq!(result, "");

        let result = normalize_text("   ");
        assert_eq!(result, "");

        println!("✅ 空字串處理測試通過");
    }

    #[test]
    fn test_normalize_text_chinese() {
        print_test_info("中文文字正規化");

        // 中文唔會被移除
        let result = normalize_text("天主教神職人員");
        assert_eq!(result, "天主教神職人員");

        // 混合中英文
        let result = normalize_text("Catholic 天主教");
        assert_eq!(result, "catholic 天主教");

        println!("✅ 中文處理測試通過");
    }

    #[test]
    fn test_contains_any_char() {
        print_test_info("字元包含檢查");

        // 基本包含測試
        assert!(contains_any_char("hello world", "h"));
        assert!(contains_any_char("hello world", "o"));
        assert!(!contains_any_char("hello world", "x"));

        // 中文字測試
        assert!(contains_any_char("天主教", "天"));
        assert!(contains_any_char("天主教", "教"));
        assert!(!contains_any_char("天主教", "佛"));

        println!("✅ 字元包含檢查測試通過");
    }

    #[test]
    fn test_extract_text_from_html() {
        print_test_info("HTML 文字提取");

        // 簡單 HTML
        let html = "<span>Hello</span>";
        let result = extract_text_from_html(html);
        assert_eq!(result, "Hello");

        // 複雜 HTML - scraper 會在文字節點之間插入空白
        let html = r#"<span style="color:red">Red</span> <span>Text</span>"#;
        let result = extract_text_from_html(html);
        // 正規化空白後比較
        let normalized_result = result.split_whitespace().collect::<Vec<_>>().join(" ");
        assert_eq!(normalized_result, "Red Text");

        // 純文字
        let html = "Plain text";
        let result = extract_text_from_html(html);
        assert_eq!(result, "Plain text");

        println!("✅ HTML 提取測試通過");
    }

    #[test]
    fn test_normalize_text_unicode() {
        print_test_info("Unicode 字符正規化");

        // 測試中文字符保留
        let result = normalize_text("神父 priest");
        assert!(result.contains("神父"));
        assert!(result.contains("priest"));

        // 測試特殊符號移除
        let result = normalize_text("Hello@World#123");
        assert_eq!(result, "helloworld123");

        println!("✅ Unicode 字符測試通過");
    }

    #[test]
    fn test_normalize_text_mixed_whitespace() {
        print_test_info("混合空白字符處理");

        let result = normalize_text("Hello\t\nWorld\r\n");
        assert_eq!(result, "hello world");

        let result = normalize_text("  \t  Hello  \n  World  \r  ");
        assert_eq!(result, "hello world");

        println!("✅ 混合空白字符測試通過");
    }
}

// 輔助函數（暫時實現，之後會移到 utils/text.rs）
fn normalize_text(text: &str) -> String {
    text.to_lowercase()
        .chars()
        .filter(|c| c.is_alphanumeric() || c.is_whitespace() || (*c as u32) >= 0x4E00)
        .collect::<String>()
        .split_whitespace()
        .collect::<Vec<_>>()
        .join(" ")
}

fn contains_any_char(text: &str, chars: &str) -> bool {
    chars.chars().any(|c| text.contains(c))
}

fn extract_text_from_html(html: &str) -> String {
    use scraper::Html;
    Html::parse_fragment(html)
        .root_element()
        .text()
        .collect::<Vec<_>>()
        .join(" ")
        .trim()
        .to_string()
}

#[cfg(test)]
mod field_inspection_tests {
    use super::*;

    #[test]
    fn test_identify_trad_in_description() {
        print_test_info("識別傳統文字喺描述入面");

        // Case 1: 完整詞語喺描述入面
        let traditional = "神父";
        let definition = "The 神父 is a priest";
        assert!(definition.contains(traditional));

        // Case 2: 個別字喺描述入面
        let traditional = "食飯";
        let definition = "To eat 飯";
        assert!(contains_any_char(definition, traditional));

        // Case 3: 唔喺描述入面
        let traditional = "學校";
        let definition = "Educational institution";
        assert!(!definition.contains(traditional));

        println!("✅ 傳統文字識別測試通過");
    }

    #[test]
    fn test_identify_same_english_and_traditional() {
        print_test_info("識別英文釋義同繁體相同");

        // Case 1: 完全相同（正規化後）
        let def = "Clergy member in Catholicism, also known as 'priest'";
        let def_trad = "Clergy member in Catholicism, also known as 'priest'";
        assert_eq!(normalize_text(def), normalize_text(def_trad));

        // Case 2: 大小寫唔同但內容相同
        let def = "SCHOOL";
        let def_trad = "school";
        assert_eq!(normalize_text(def), normalize_text(def_trad));

        // Case 3: 唔相同
        let def = "priest";
        let def_trad = "天主教神職人員";
        assert_ne!(normalize_text(def), normalize_text(def_trad));

        println!("✅ 英文釋義比較測試通過");
    }

    #[test]
    fn test_mock_note_data() {
        print_test_info("模擬筆記數據");

        let notes = MockAnkiResponses::notes_info();
        let notes_array = notes["result"].as_array().unwrap();

        // 驗證筆記數量
        assert_eq!(notes_array.len(), 3);

        // 驗證第一個筆記
        let note1 = &notes_array[0];
        assert_eq!(note1["noteId"], 2001);
        assert_eq!(note1["fields"]["Traditional"]["value"], "神父");

        // 驗證有問題嘅筆記（第三個）
        let note3 = &notes_array[2];
        let def = note3["fields"]["Definition"]["value"].as_str().unwrap();
        let def_trad = note3["fields"]["Definitions Traditional"]["value"]
            .as_str()
            .unwrap();

        // 呢個筆記嘅 Definition 同 Definitions Traditional 係相同嘅（有問題）
        assert_eq!(def, def_trad);

        println!("✅ 模擬數據驗證通過");
    }

    #[test]
    fn test_find_duplicate_traditional() {
        print_test_info("搵出重複嘅 Traditional 欄位");

        use std::collections::HashMap;

        // 創建模擬嘅重複數據
        let mut traditional_map: HashMap<String, Vec<u64>> = HashMap::new();

        // 模擬：兩個筆記有相同嘅 "神父"
        traditional_map.insert("神父".to_string(), vec![2001, 2004]);

        // 模擬：三個筆記有相同嘅 "學校"
        traditional_map.insert("學校".to_string(), vec![2002, 2005, 2006]);

        // 模擬：獨特嘅筆記（唔應該出現喺重複列表）
        traditional_map.insert("食飯".to_string(), vec![2003]);

        // 過濾出重複項（多於一個筆記）
        let duplicates: HashMap<String, Vec<u64>> = traditional_map
            .into_iter()
            .filter(|(_, ids)| ids.len() > 1)
            .collect();

        // 驗證結果
        assert_eq!(duplicates.len(), 2); // 應該有兩組重複
        assert!(duplicates.contains_key("神父"));
        assert!(duplicates.contains_key("學校"));
        assert!(!duplicates.contains_key("食飯")); // 唔應該包含獨特項

        // 驗證 "神父" 有 2 個重複
        assert_eq!(duplicates.get("神父").unwrap().len(), 2);

        // 驗證 "學校" 有 3 個重複
        assert_eq!(duplicates.get("學校").unwrap().len(), 3);

        println!("✅ 重複檢測邏輯測試通過");
    }
}

#[cfg(test)]
mod update_operations_tests {
    use super::*;

    #[test]
    fn test_update_fields_structure() {
        print_test_info("更新欄位結構");

        let mut updates: HashMap<String, String> = HashMap::new();

        // 模擬更新操作
        updates.insert(
            "Definitions Traditional".to_string(),
            "天主教神職人員".to_string(),
        );
        updates.insert(
            "Definitions Jyutping".to_string(),
            "tin1 zyu2 gaau3 san4 zik1 jan4 jyun4".to_string(),
        );
        updates.insert("Colors Definitions Traditional".to_string(), String::new());

        // 驗證更新包含預期欄位
        assert!(assert_update_contains_field(
            &updates,
            "Definitions Traditional"
        ));
        assert!(assert_update_contains_field(
            &updates,
            "Definitions Jyutping"
        ));
        assert!(assert_update_contains_field(
            &updates,
            "Colors Definitions Traditional"
        ));

        // 驗證欄位內容
        assert_eq!(
            updates.get("Definitions Traditional").unwrap(),
            "天主教神職人員"
        );

        // 驗證清空欄位
        assert_eq!(updates.get("Colors Definitions Traditional").unwrap(), "");

        println!("✅ 更新欄位結構測試通過");
    }

    #[test]
    fn test_ai_response_parsing() {
        print_test_info("AI 回應解析");

        let ai_response = MockAiResponses::generate_definitions();
        let parsed: serde_json::Value = serde_json::from_str(&ai_response).unwrap();

        // 驗證 JSON 結構
        assert!(parsed.get("Definitions English").is_some());
        assert!(parsed.get("Definitions Traditional").is_some());

        // 驗證內容
        let eng = parsed["Definitions English"].as_str().unwrap();
        let trad = parsed["Definitions Traditional"].as_str().unwrap();

        assert!(!eng.is_empty());
        assert!(!trad.is_empty());
        assert!(eng.contains("Catholic"));
        assert!(trad.contains("天主教"));

        println!("✅ AI 回應解析測試通過");
    }

    #[test]
    fn test_clear_fields_after_ai_update() {
        print_test_info("AI 更新後清空欄位");

        let mut updates: HashMap<String, String> = HashMap::new();

        // 模擬 AI 更新
        updates.insert(
            "Definitions English".to_string(),
            "New definition".to_string(),
        );
        updates.insert("Definitions Traditional".to_string(), "新釋義".to_string());
        updates.insert("Definition".to_string(), "New definition".to_string());

        // 清空需要重新生成嘅欄位
        updates.insert("Definitions Jyutping".to_string(), String::new());
        updates.insert("Colors Definitions Traditional".to_string(), String::new());

        // 驗證清空操作
        assert_eq!(updates.get("Definitions Jyutping").unwrap(), "");
        assert_eq!(updates.get("Colors Definitions Traditional").unwrap(), "");

        // 驗證其他欄位仍然有值
        assert!(!updates.get("Definitions English").unwrap().is_empty());
        assert!(!updates.get("Definitions Traditional").unwrap().is_empty());

        println!("✅ 清空欄位測試通過");
    }
}

#[cfg(test)]
mod export_deck_tests {
    use super::*;

    #[test]
    fn test_export_deck_response_structure() {
        print_test_info("導出牌組響應結構");

        // 測試成功響應
        let success_response = MockAnkiResponses::export_deck_success();
        assert!(success_response.get("result").is_some());
        assert!(success_response.get("error").is_some());
        assert_eq!(success_response["result"], true);
        assert_eq!(success_response["error"], serde_json::Value::Null);

        // 測試失敗響應
        let failure_response = MockAnkiResponses::export_deck_failure();
        assert!(failure_response.get("result").is_some());
        assert!(failure_response.get("error").is_some());
        assert_eq!(failure_response["result"], false);
        assert!(failure_response["error"].as_str().is_some());
        assert!(failure_response["error"]
            .as_str()
            .unwrap()
            .contains("Failed to export"));

        println!("✅ 導出牌組響應結構測試通過");
    }

    #[test]
    fn test_export_deck_with_schedule() {
        print_test_info("導出牌組包含學習進度");

        let response = MockAnkiResponses::export_deck_success();

        // 驗證響應結構
        assert_eq!(response["result"], true);
        assert_eq!(response["error"], serde_json::Value::Null);

        println!("✅ 包含學習進度導出測試通過");
    }

    #[test]
    fn test_export_deck_without_schedule() {
        print_test_info("導出牌組唔包含學習進度");

        let response = MockAnkiResponses::export_deck_success();

        // includeSched 參數唔影響響應結構，只影響導出嘅文件內容
        assert_eq!(response["result"], true);
        assert_eq!(response["error"], serde_json::Value::Null);

        println!("✅ 唔包含學習進度導出測試通過");
    }

    #[test]
    fn test_export_deck_error_handling() {
        print_test_info("導出牌組錯誤處理");

        let error_response = MockAnkiResponses::export_deck_failure();

        // 驗證錯誤響應
        assert_eq!(error_response["result"], false);
        assert!(error_response["error"].is_string());

        let error_msg = error_response["error"].as_str().unwrap();
        assert!(!error_msg.is_empty());
        assert!(error_msg.contains("Failed to export"));

        println!("✅ 錯誤處理測試通過");
    }
}

#[cfg(test)]
mod anki_response_tests {
    use super::*;

    #[test]
    fn test_deck_names_response() {
        print_test_info("牌組列表回應");

        let response = MockAnkiResponses::deck_names();

        assert!(response.get("result").is_some());
        assert!(response.get("error").is_some());

        let deck_names = response["result"].as_array().unwrap();
        assert_eq!(deck_names.len(), 2);
        assert_eq!(deck_names[0], "測試牌組");

        println!("✅ 牌組列表回應測試通過");
    }

    #[test]
    fn test_notes_info_response() {
        print_test_info("筆記資訊回應");

        let response = MockAnkiResponses::notes_info();
        let notes = response["result"].as_array().unwrap();

        assert_eq!(notes.len(), 3);

        // 檢查每個筆記都有必要欄位
        for note in notes {
            assert!(note.get("noteId").is_some());
            assert!(note.get("fields").is_some());

            let fields = note["fields"].as_object().unwrap();
            assert!(fields.contains_key("Traditional"));
            assert!(fields.contains_key("Definition"));
        }

        println!("✅ 筆記資訊回應測試通過");
    }

    #[test]
    fn test_update_note_response() {
        print_test_info("更新筆記回應");

        let response = MockAnkiResponses::update_note_success();

        assert_eq!(response["error"], json!(null));
        assert_eq!(response["result"], json!(null));

        println!("✅ 更新筆記回應測試通過");
    }
}
