// 共用測試工具

use serde_json::json;
use std::collections::HashMap;

/// Mock AnkiConnect 回應
#[allow(dead_code)]
pub struct MockAnkiResponses;

impl MockAnkiResponses {
    /// 創建模擬嘅牌組列表回應
    #[allow(dead_code)]
    pub fn deck_names() -> serde_json::Value {
        json!({
            "result": ["測試牌組", "另一個牌組"],
            "error": null
        })
    }

    /// 創建模擬嘅卡片 ID 列表回應
    #[allow(dead_code)]
    pub fn card_ids() -> serde_json::Value {
        json!({
            "result": [1001, 1002, 1003],
            "error": null
        })
    }

    /// 創建模擬嘅筆記 ID 列表回應
    #[allow(dead_code)]
    pub fn note_ids() -> serde_json::Value {
        json!({
            "result": [2001, 2002, 2003],
            "error": null
        })
    }

    /// 創建模擬嘅卡片資訊回應
    #[allow(dead_code)]
    pub fn cards_info() -> serde_json::Value {
        json!({
            "result": [
                {
                    "cardId": 1001,
                    "deckName": "測試牌組",
                    "modelName": "Basic",
                },
                {
                    "cardId": 1002,
                    "deckName": "測試牌組",
                    "modelName": "Basic",
                }
            ],
            "error": null
        })
    }

    /// 創建模擬嘅筆記資訊回應
    #[allow(dead_code)]
    pub fn notes_info() -> serde_json::Value {
        json!({
            "result": [
                {
                    "noteId": 2001,
                    "mod": 1234567890,
                    "modelName": "Basic",
                    "fields": {
                        "Traditional": {"value": "神父", "order": 0},
                        "Simplified": {"value": "神父", "order": 1},
                        "Jyutping": {"value": "san4 fu6", "order": 2},
                        "Definition": {"value": "priest", "order": 3},
                        "Definitions English": {"value": "Clergy member in Catholicism", "order": 4},
                        "Definitions Traditional": {"value": "天主教神職人員", "order": 5},
                        "Definitions Jyutping": {"value": "tin1 zyu2 gaau3 san4 zik1 jan4 jyun4", "order": 6},
                        "Grammar type": {"value": "名詞", "order": 7},
                        "Colors Traditional": {"value": "", "order": 8},
                        "Colors Definitions Traditional": {"value": "", "order": 9}
                    }
                },
                {
                    "noteId": 2002,
                    "mod": 1234567890,
                    "modelName": "Basic",
                    "fields": {
                        "Traditional": {"value": "學校", "order": 0},
                        "Simplified": {"value": "学校", "order": 1},
                        "Jyutping": {"value": "hok6 haau6", "order": 2},
                        "Definition": {"value": "school", "order": 3},
                        "Definitions English": {"value": "Educational institution", "order": 4},
                        "Definitions Traditional": {"value": "教育機構", "order": 5},
                        "Definitions Jyutping": {"value": "gaau3 juk6 gei1 kau3", "order": 6},
                        "Grammar type": {"value": "名詞", "order": 7},
                        "Colors Traditional": {"value": "", "order": 8},
                        "Colors Definitions Traditional": {"value": "", "order": 9}
                    }
                },
                {
                    "noteId": 2003,
                    "mod": 1234567890,
                    "modelName": "Basic",
                    "fields": {
                        "Traditional": {"value": "食飯", "order": 0},
                        "Simplified": {"value": "吃饭", "order": 1},
                        "Jyutping": {"value": "sik6 faan6", "order": 2},
                        "Definition": {"value": "Clergy member in Catholicism, also known as 'priest'", "order": 3},
                        "Definitions English": {"value": "", "order": 4},
                        "Definitions Traditional": {"value": "Clergy member in Catholicism, also known as 'priest'", "order": 5},
                        "Definitions Jyutping": {"value": "", "order": 6},
                        "Grammar type": {"value": "", "order": 7},
                        "Colors Traditional": {"value": "", "order": 8},
                        "Colors Definitions Traditional": {"value": "", "order": 9}
                    }
                }
            ],
            "error": null
        })
    }

    /// 創建模擬嘅更新筆記回應
    #[allow(dead_code)]
    pub fn update_note_success() -> serde_json::Value {
        json!({
            "result": null,
            "error": null
        })
    }

    /// 創建模擬嘅導出牌組成功回應
    #[allow(dead_code)]
    pub fn export_deck_success() -> serde_json::Value {
        json!({
            "result": true,
            "error": null
        })
    }

    /// 創建模擬嘅導出牌組失敗回應
    #[allow(dead_code)]
    pub fn export_deck_failure() -> serde_json::Value {
        json!({
            "result": false,
            "error": "Failed to export deck: deck not found"
        })
    }
}

/// Mock OpenAI 回應
#[allow(dead_code)]
pub struct MockAiResponses;

impl MockAiResponses {
    /// 創建模擬嘅 AI 回應（生成釋義）
    #[allow(dead_code)]
    pub fn generate_definitions() -> String {
        json!({
            "Definitions English": "A member of the Catholic clergy who performs religious ceremonies",
            "Definitions Traditional": "執行宗教儀式嘅天主教神職人員"
        })
        .to_string()
    }

    /// 創建模擬嘅 AI 回應（處理唔完整嘅筆記）
    #[allow(dead_code)]
    pub fn process_incomplete_note() -> String {
        json!({
            "Traditional": "神父",
            "Definition": "priest",
            "Simplified": "神父",
            "Definitions English": "Catholic clergy member",
            "Definitions Traditional": "天主教神職人員",
            "Grammar type": "名詞"
        })
        .to_string()
    }
}

/// 創建測試用嘅欄位 HashMap
#[allow(dead_code)]
pub fn create_test_fields() -> HashMap<String, serde_json::Value> {
    let mut fields = HashMap::new();

    fields.insert(
        "Traditional".to_string(),
        json!({"value": "神父", "order": 0}),
    );
    fields.insert(
        "Simplified".to_string(),
        json!({"value": "神父", "order": 1}),
    );
    fields.insert(
        "Jyutping".to_string(),
        json!({"value": "san4 fu6", "order": 2}),
    );
    fields.insert(
        "Definition".to_string(),
        json!({"value": "priest", "order": 3}),
    );

    fields
}

/// 驗證筆記更新係咪包含預期欄位
#[allow(dead_code)]
pub fn assert_update_contains_field(updates: &HashMap<String, String>, field_name: &str) -> bool {
    updates.contains_key(field_name)
}

/// 打印測試信息（用粵語）
pub fn print_test_info(test_name: &str) {
    println!("\n🧪 測試: {}", test_name);
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
}
