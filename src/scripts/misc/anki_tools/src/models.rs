#![allow(dead_code)]

use scraper::Html;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{collections::HashMap, fmt::Display};

use crate::jyutping_reader::JyutpingReader;
use crate::utils::constants::POSSIBLE_GRAMMAR_TYPES;
use crate::utils::text::normalize_text;
use crate::{anki_connect_client::AnkiConnectClient, open_ai_client::OpenAiClient};

pub struct ModelsClients {
    pub anki_client: AnkiConnectClient,
    pub open_ai_client: OpenAiClient,
}

#[derive(Debug, Serialize, Deserialize)]
enum ChineseNoteFields {
    Traditional,
    Simplified,
    Jyutping,
    Definition,
    DefinitionsJyutping,
    DefinitionsEnglish,
    DefinitionsTraditional,
    GrammarType,
    ColorsTraditional,
    ColorsDefinitionsTraditional,
}

impl ChineseNoteFields {
    const fn as_str(&self) -> &'static str {
        match self {
            ChineseNoteFields::Traditional => "Traditional",
            ChineseNoteFields::Simplified => "Simplified",
            ChineseNoteFields::Jyutping => "Jyutping",
            ChineseNoteFields::Definition => "Definition",
            ChineseNoteFields::DefinitionsJyutping => "Definitions Jyutping",
            ChineseNoteFields::DefinitionsEnglish => "Definitions English",
            ChineseNoteFields::DefinitionsTraditional => "Definitions Traditional",
            ChineseNoteFields::GrammarType => "Grammar type",
            ChineseNoteFields::ColorsTraditional => "Colors Traditional",
            ChineseNoteFields::ColorsDefinitionsTraditional => "Colors Definitions Traditional",
        }
    }
}

impl Display for ChineseNoteFields {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl TryFrom<&str> for ChineseNoteFields {
    type Error = String;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        match value {
            s if s == ChineseNoteFields::Traditional.as_str() => Ok(ChineseNoteFields::Traditional),
            s if s == ChineseNoteFields::Simplified.as_str() => Ok(ChineseNoteFields::Simplified),
            s if s == ChineseNoteFields::Jyutping.as_str() => Ok(ChineseNoteFields::Jyutping),
            s if s == ChineseNoteFields::Definition.as_str() => Ok(ChineseNoteFields::Definition),
            s if s == ChineseNoteFields::DefinitionsJyutping.as_str() => {
                Ok(ChineseNoteFields::DefinitionsJyutping)
            }
            s if s == ChineseNoteFields::DefinitionsEnglish.as_str() => {
                Ok(ChineseNoteFields::DefinitionsEnglish)
            }
            s if s == ChineseNoteFields::DefinitionsTraditional.as_str() => {
                Ok(ChineseNoteFields::DefinitionsTraditional)
            }
            s if s == ChineseNoteFields::GrammarType.as_str() => Ok(ChineseNoteFields::GrammarType),
            s if s == ChineseNoteFields::ColorsTraditional.as_str() => {
                Ok(ChineseNoteFields::ColorsTraditional)
            }
            s if s == ChineseNoteFields::ColorsDefinitionsTraditional.as_str() => {
                Ok(ChineseNoteFields::ColorsDefinitionsTraditional)
            }
            _ => Err(format!("未知欄位: {}", value)),
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
struct Field {
    order: u64,
    value: String,
    field_type: ChineseNoteFields,
}

pub struct Note<'a> {
    id: u64,
    deck_name: String,
    model_name: String,
    model_id: u64,
    fields: HashMap<String, Field>,
    model_clients: &'a ModelsClients,
}

impl<'a> Note<'a> {
    fn get_processed_field(&self, field: ChineseNoteFields) -> Option<String> {
        if let Some(f) = self.fields.get(field.as_str()) {
            let value = f.value.trim();
            if !value.is_empty() {
                let parsed_text = Html::parse_fragment(value)
                    .root_element()
                    .text()
                    .collect::<Vec<_>>()
                    .join(" ")
                    .trim()
                    .to_string();
                return Some(parsed_text);
            }
        }

        None
    }

    /// 直接攞欄位原始字串（唔做 HTML 解析），方便做等值比較
    fn get_raw_field(&self, field: ChineseNoteFields) -> Option<String> {
        self.fields
            .get(field.as_str())
            .map(|f| f.value.clone())
            .and_then(|s| {
                let t = s.trim().to_string();
                if t.is_empty() {
                    None
                } else {
                    Some(t)
                }
            })
    }

    fn guess_grammar_type(&self) -> Option<String> {
        if let Some(grammar_field) = self.get_processed_field(ChineseNoteFields::GrammarType) {
            return Some(grammar_field);
        }
        let definition_field = self.get_processed_field(ChineseNoteFields::Definition);
        let traditional_field = self.get_processed_field(ChineseNoteFields::Traditional);
        let simplified_field = self.get_processed_field(ChineseNoteFields::Simplified);

        if let Some(guessed_grammar_type) = [simplified_field, traditional_field, definition_field]
            .iter()
            .find_map(|field_option| {
                if let Some(field) = field_option {
                    for grammar_type in POSSIBLE_GRAMMAR_TYPES {
                        if field.contains(grammar_type) {
                            return Some(grammar_type.to_string());
                        }
                    }
                }
                None
            })
        {
            return Some(guessed_grammar_type);
        }

        None
    }
}

pub struct Card<'a> {
    id: u64,
    deck_name: String,
    model_name: String,
    models_clients: &'a ModelsClients,
}

impl<'a> Card<'a> {
    pub fn print(&self) {
        println!("卡片 ID：{}", self.id);
        println!("牌組名稱：{}", self.deck_name);
    }
}

pub struct Deck<'a> {
    pub cards_ids: Vec<u64>,
    pub card_id_to_card: HashMap<u64, Card<'a>>,
    pub notes_ids: Vec<u64>,
    pub note_id_to_note: HashMap<u64, Note<'a>>,
    deck_name: String,
    models_clients: &'a ModelsClients,
}

impl<'a> Deck<'a> {
    pub async fn get_from_name(
        models_clients: &'a ModelsClients,
        deck_name: &str,
    ) -> Result<Deck<'a>, Box<dyn std::error::Error>> {
        let mut deck = Deck {
            cards_ids: vec![],
            card_id_to_card: HashMap::new(),
            notes_ids: vec![],
            note_id_to_note: HashMap::new(),
            deck_name: deck_name.to_string(),
            models_clients,
        };

        deck.sync().await?;
        Ok(deck)
    }

    pub async fn sync(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        let cards_ids_response = self
            .models_clients
            .anki_client
            .find_cards(&self.deck_name)
            .await?;
        self.cards_ids = cards_ids_response.result;
        let cards_info_response = self
            .models_clients
            .anki_client
            .get_cards_info(&self.cards_ids)
            .await?;
        let cards_info = cards_info_response.result;
        self.card_id_to_card.clear();

        for card in cards_info.as_array().unwrap() {
            let id = card["cardId"].as_u64().unwrap();
            let deck_name = card["deckName"].as_str().unwrap().to_string();
            let model_name = card["modelName"].as_str().unwrap().to_string();

            self.card_id_to_card.insert(
                id,
                Card {
                    id,
                    deck_name,
                    model_name,
                    models_clients: self.models_clients,
                },
            );
        }

        let notes_ids_response = self
            .models_clients
            .anki_client
            .find_notes(&self.deck_name)
            .await?;
        self.notes_ids = notes_ids_response.result;
        let notes_info_response = self
            .models_clients
            .anki_client
            .get_notes_info(&self.notes_ids)
            .await?;
        let notes_info = notes_info_response.result;
        self.note_id_to_note.clear();

        for _note in notes_info.as_array().unwrap() {
            let id = _note["noteId"].as_u64().unwrap();
            let model_id = _note["mod"].as_u64().unwrap();
            let _model_name = _note["modelName"].as_str().unwrap().to_string();
            let _fields_json = &_note["fields"];

            let mut fields = HashMap::new();
            for (field_name, field_value) in _fields_json.as_object().unwrap() {
                let order = field_value["order"].as_u64().unwrap();
                let value = field_value["value"].as_str().unwrap().to_string();

                // 將欄位名稱轉換為 ChineseNoteFields 枚舉
                let Ok(field_type) = ChineseNoteFields::try_from(field_name.as_str()) else {
                    continue; // 忽略未知欄位
                };

                fields.insert(
                    field_type.to_string(),
                    Field {
                        order,
                        value,
                        field_type,
                    },
                );
            }

            self.note_id_to_note.insert(
                id,
                Note {
                    model_id,
                    id,
                    deck_name: self.deck_name.clone(),
                    model_name: _model_name,
                    fields,
                    model_clients: self.models_clients,
                },
            );
        }

        Ok(())
    }

    pub async fn get_config(&'a self) -> Result<Value, Box<dyn std::error::Error>> {
        let config = self
            .models_clients
            .anki_client
            .get_deck_config(&self.card_id_to_card[&self.cards_ids[0]].deck_name)
            .await?;

        Ok(config.result)
    }

    pub fn get_incomplete_notes(&'a self) -> Vec<&'a Note<'a>> {
        let mut incomplete_notes = Vec::new();

        for note in self.note_id_to_note.values() {
            if [
                "Definition",
                "Traditional",
                "Definitions Traditional",
                "Definitions English",
            ]
            .iter()
            .any(|field_name| {
                let field = note.fields.get(*field_name);
                field.is_none() || field.unwrap().value.trim().is_empty()
            }) {
                incomplete_notes.push(note);
                continue;
            }
        }

        incomplete_notes
    }

    /// 檢查欄位，尋找傳統文字出現喺描述入面嘅筆記
    /// 返回兩組筆記 ID：(傳統文字喺描述入面嘅筆記, 英文釋義同繁體/粵拼相同嘅筆記)
    pub fn inspect_fields(&self) -> (Vec<u64>, Vec<u64>) {
        let mut trad_in_desc_notes_full = Vec::new();
        let mut trad_in_desc_notes_partial = Vec::new();
        let mut same_english_notes = Vec::new();

        for note in self.note_id_to_note.values() {
            let traditional = note.get_processed_field(ChineseNoteFields::Traditional);
            let definition = note.get_processed_field(ChineseNoteFields::Definition);
            let definitions_english =
                note.get_processed_field(ChineseNoteFields::DefinitionsEnglish);
            let definitions_traditional =
                note.get_processed_field(ChineseNoteFields::DefinitionsTraditional);
            let definitions_jyutping =
                note.get_processed_field(ChineseNoteFields::DefinitionsJyutping);

            // 檢查傳統文字係咪出現喺描述入面
            if let Some(trad) = traditional.as_ref() {
                let mut found_full = false;
                let mut found_all_chars = false;

                // 收集所有要檢查嘅文字
                let mut all_text = String::new();
                if let Some(def) = definition.as_ref() {
                    all_text.push_str(def);
                }
                if let Some(eng) = definitions_english.as_ref() {
                    all_text.push_str(eng);
                }
                if let Some(def_trad) = definitions_traditional.as_ref() {
                    all_text.push_str(def_trad);
                }

                // 檢查係咪包含完整詞語
                if all_text.contains(trad) {
                    found_full = true;
                } else {
                    // 檢查係咪所有字符都出現咗（即使分散）
                    found_all_chars = trad.chars().all(|c| all_text.contains(c));
                }

                if found_full {
                    trad_in_desc_notes_full.push(note);
                } else if found_all_chars {
                    trad_in_desc_notes_partial.push(note);
                }
            }

            // 檢查英文釋義係咪同 Definitions Traditional/Jyutping 相同（正規化後）
            let mut is_same = false;

            // 比較 Definition 同 Definitions Traditional
            if let (Some(def), Some(def_trad)) =
                (definition.as_ref(), definitions_traditional.as_ref())
            {
                let normalized_def = normalize_text(def);
                let normalized_def_trad = normalize_text(def_trad);
                if normalized_def == normalized_def_trad && !normalized_def.is_empty() {
                    is_same = true;
                }
            }

            // 比較 Definition 同 Definitions Jyutping
            if !is_same {
                if let (Some(def), Some(def_jyut)) =
                    (definition.as_ref(), definitions_jyutping.as_ref())
                {
                    let normalized_def = normalize_text(def);
                    let normalized_def_jyut = normalize_text(def_jyut);
                    if normalized_def == normalized_def_jyut && !normalized_def.is_empty() {
                        is_same = true;
                    }
                }
            }

            // 比較 Definitions English 同 Definitions Traditional
            if !is_same {
                if let (Some(eng), Some(def_trad)) = (
                    definitions_english.as_ref(),
                    definitions_traditional.as_ref(),
                ) {
                    let normalized_eng = normalize_text(eng);
                    let normalized_def_trad = normalize_text(def_trad);
                    if normalized_eng == normalized_def_trad && !normalized_eng.is_empty() {
                        is_same = true;
                    }
                }
            }

            // 比較 Definitions English 同 Definitions Jyutping
            if !is_same {
                if let (Some(eng), Some(def_jyut)) =
                    (definitions_english.as_ref(), definitions_jyutping.as_ref())
                {
                    let normalized_eng = normalize_text(eng);
                    let normalized_def_jyut = normalize_text(def_jyut);
                    if normalized_eng == normalized_def_jyut && !normalized_eng.is_empty() {
                        is_same = true;
                    }
                }
            }

            if is_same {
                same_english_notes.push(note);
            }
        }

        // 合併全字同部分匹配嘅筆記（優先顯示全字匹配）
        let mut trad_in_desc_notes: Vec<&Note> = Vec::new();
        trad_in_desc_notes.extend(&trad_in_desc_notes_full);
        trad_in_desc_notes.extend(&trad_in_desc_notes_partial);

        // 顯示第一組：傳統文字出現喺描述入面嘅筆記
        if trad_in_desc_notes.is_empty() {
            println!("\n搵到 0 個筆記嘅傳統文字出現喺描述入面\n");
        } else {
            println!(
                "\n搵到 {} 個筆記嘅傳統文字出現喺描述入面：\n",
                trad_in_desc_notes.len()
            );
            if !trad_in_desc_notes_full.is_empty() {
                println!("  - {} 個全字匹配", trad_in_desc_notes_full.len());
            }
            if !trad_in_desc_notes_partial.is_empty() {
                println!(
                    "  - {} 個所有字匹配（分散）",
                    trad_in_desc_notes_partial.len()
                );
            }
            println!();
        }

        // 收集用戶確認要更新嘅筆記 ID
        let mut confirmed_trad_note_ids = Vec::new();
        let total_trad_notes = trad_in_desc_notes.len();

        for (idx, note) in trad_in_desc_notes.iter().enumerate() {
            println!("───────────────────────────────────────");
            let match_type = if idx < trad_in_desc_notes_full.len() {
                "全字匹配"
            } else {
                "所有字匹配"
            };
            println!(
                "筆記 #{}/{} (ID: {}) [{}]",
                idx + 1,
                total_trad_notes,
                note.id,
                match_type
            );
            println!();

            self.print_note_fields(note);
            println!();

            confirmed_trad_note_ids.push(note.id);
        }

        if trad_in_desc_notes.is_empty() {
            println!("冇搵到符合條件嘅筆記。");
        } else {
            println!("\n已確認 {} 個筆記進行更新", confirmed_trad_note_ids.len());
        }

        // 顯示第二組：英文釋義同繁體/粵拼相同嘅筆記
        if same_english_notes.is_empty() {
            println!("\n搵到 0 個筆記嘅英文釋義同繁體/粵拼相同\n");
        } else {
            println!(
                "\n搵到 {} 個筆記嘅英文釋義同繁體/粵拼相同：\n",
                same_english_notes.len()
            );
        }

        for (idx, note) in same_english_notes.iter().enumerate() {
            println!("───────────────────────────────────────");
            println!("筆記 #{} (ID: {})", idx + 1, note.id);
            println!();

            self.print_note_fields(note);
            println!();
        }

        if same_english_notes.is_empty() {
            println!("冇搵到符合條件嘅筆記。");
        }

        let same_note_ids: Vec<u64> = same_english_notes.iter().map(|n| n.id).collect();

        // 返回用戶確認嘅筆記 ID
        (confirmed_trad_note_ids, same_note_ids)
    }

    /// 搵出 Traditional 欄位重複嘅筆記
    /// 返回 HashMap：Traditional 文字 -> 筆記 ID 列表
    pub fn find_duplicate_traditional(&self) -> HashMap<String, Vec<u64>> {
        let mut traditional_map: HashMap<String, Vec<u64>> = HashMap::new();

        // 建立 Traditional -> note_ids 映射
        for note in self.note_id_to_note.values() {
            if let Some(trad) = note.get_processed_field(ChineseNoteFields::Traditional) {
                let trimmed = trad.trim();
                if !trimmed.is_empty() {
                    traditional_map
                        .entry(trimmed.to_string())
                        .or_default()
                        .push(note.id);
                }
            }
        }

        // 只保留有重複嘅（超過一個筆記）
        let duplicates: HashMap<String, Vec<u64>> = traditional_map
            .into_iter()
            .filter(|(_, ids)| ids.len() > 1)
            .collect();

        // 顯示結果
        if duplicates.is_empty() {
            println!("\n搵到 0 個重複嘅 Traditional 欄位\n");
        } else {
            let total_duplicates: usize = duplicates.values().map(|ids| ids.len()).sum();
            println!(
                "\n搵到 {} 組重複嘅 Traditional 欄位（共 {} 個筆記）：\n",
                duplicates.len(),
                total_duplicates
            );

            // 按筆記數量排序（最多重複嘅排前面）
            let mut sorted_duplicates: Vec<_> = duplicates.iter().collect();
            sorted_duplicates.sort_by(|a, b| b.1.len().cmp(&a.1.len()));

            for (idx, (trad, note_ids)) in sorted_duplicates.iter().enumerate() {
                println!("═══════════════════════════════════════");
                println!(
                    "重複組 #{} - \"{}\" ({} 個筆記)",
                    idx + 1,
                    trad,
                    note_ids.len()
                );
                println!();

                for (note_idx, note_id) in note_ids.iter().enumerate() {
                    if let Some(note) = self.note_id_to_note.get(note_id) {
                        println!("  筆記 {} (ID: {})", note_idx + 1, note_id);

                        // 只顯示關鍵欄位以節省空間
                        if let Some(def) = note.get_processed_field(ChineseNoteFields::Definition) {
                            if !def.is_empty() {
                                println!("    釋義：{}", def);
                            }
                        }
                        if let Some(def_eng) =
                            note.get_processed_field(ChineseNoteFields::DefinitionsEnglish)
                        {
                            if !def_eng.is_empty() {
                                println!("    英文釋義：{}", def_eng);
                            }
                        }
                        if let Some(grammar) =
                            note.get_processed_field(ChineseNoteFields::GrammarType)
                        {
                            if !grammar.is_empty() {
                                println!("    語法類型：{}", grammar);
                            }
                        }
                        println!();
                    }
                }
            }
        }

        duplicates
    }

    /// 打印筆記嘅所有欄位
    fn print_note_fields(&self, note: &Note) {
        let mut sorted_fields: Vec<_> = note.fields.values().collect();
        sorted_fields.sort_by_key(|f| f.order);

        for field in sorted_fields {
            let processed_value = Html::parse_fragment(&field.value)
                .root_element()
                .text()
                .collect::<Vec<_>>()
                .join(" ")
                .trim()
                .to_string();

            if !processed_value.is_empty() {
                println!("  {}: {}", field.field_type, processed_value);
            }
        }
    }

    /// 更新筆記，將指定欄位設置為英文釋義
    pub async fn update_notes_with_english_definition(
        &self,
        note_ids: &[u64],
    ) -> Result<(), Box<dyn std::error::Error>> {
        let mut updated_notes = 0;
        let mut failed_notes = 0;

        for note_id in note_ids {
            let Some(note) = self.note_id_to_note.get(note_id) else {
                failed_notes += 1;
                continue;
            };

            let Some(english_def) = note.get_processed_field(ChineseNoteFields::DefinitionsEnglish)
            else {
                println!("筆記 {} 冇英文釋義，跳過", note_id);
                failed_notes += 1;
                continue;
            };

            let mut updates = std::collections::HashMap::new();
            updates.insert(
                ChineseNoteFields::DefinitionsTraditional
                    .as_str()
                    .to_string(),
                english_def.clone(),
            );
            updates.insert(
                ChineseNoteFields::DefinitionsJyutping.as_str().to_string(),
                english_def.clone(),
            );
            updates.insert(
                ChineseNoteFields::ColorsDefinitionsTraditional
                    .as_str()
                    .to_string(),
                english_def.clone(),
            );
            updates.insert(
                ChineseNoteFields::DefinitionsEnglish.as_str().to_string(),
                english_def.clone(),
            );
            updates.insert(
                ChineseNoteFields::Definition.as_str().to_string(),
                english_def.clone(),
            );

            if self
                .models_clients
                .anki_client
                .update_note_fields(*note_id, updates)
                .await
                .is_err()
            {
                println!("筆記 {} 更新失敗", note_id);
                failed_notes += 1;
                continue;
            }

            updated_notes += 1;
        }

        println!("\n更新完成：");
        println!("  成功：{}", updated_notes);
        println!("  失敗：{}", failed_notes);

        Ok(())
    }

    /// 用 AI 生成新嘅釋義來更新筆記
    /// 生成不包含繁體欄位內字詞嘅釋義
    pub async fn update_notes_with_ai_definitions(
        &self,
        note_ids: &[u64],
    ) -> Result<(), Box<dyn std::error::Error>> {
        let mut updated_notes = 0;
        let mut failed_notes = 0;
        let mut skipped_notes = 0;

        for (idx, note_id) in note_ids.iter().enumerate() {
            let Some(note) = self.note_id_to_note.get(note_id) else {
                failed_notes += 1;
                continue;
            };

            let Some(traditional) = note.get_processed_field(ChineseNoteFields::Traditional) else {
                println!("筆記 {} 冇傳統文字，跳過", note_id);
                skipped_notes += 1;
                continue;
            };

            // 獲取現有嘅定義（優先順序：Definition > DefinitionsEnglish > DefinitionsTraditional）
            let existing_definition = note
                .get_processed_field(ChineseNoteFields::Definition)
                .or_else(|| note.get_processed_field(ChineseNoteFields::DefinitionsEnglish))
                .or_else(|| note.get_processed_field(ChineseNoteFields::DefinitionsTraditional));

            print!("\r處理中：{}/{}", idx + 1, note_ids.len());
            std::io::Write::flush(&mut std::io::stdout()).ok();

            // 構造 AI 提示
            let prompt = if let Some(existing_def) = existing_definition {
                format!(
                    "你係一個粵語同漢字專家。根據以下繁體中文詞語同現有釋義，產生改進嘅 JSON 物件，\n\
                    鍵必須為：Definitions English, Definitions Traditional\n\n\
                    規則：\n\
                    - 唔好加入多餘文字或說明，只輸出 JSON。\n\
                    - Definitions English：必須用英文，而且係詳細嘅釋義或例句。\n\
                    - Definitions Traditional：必須用繁體中文，係 Definitions English 嘅翻譯。\n\
                    - 重要：釋義不可以包含以下繁體中文詞語嘅任何字：'{}'\n\
                    - 釋義必須用不同嘅詞語來解釋意思，或者提供例句。\n\
                    - 參考現有釋義但要改進佢，令佢更清晰、更詳細。\n\n\
                    繁體中文詞語：{}\n\
                    現有釋義：{}\n\n\
                    只輸出 JSON。",
                    traditional, traditional, existing_def
                )
            } else {
                format!(
                    "你係一個粵語同漢字專家。根據以下繁體中文詞語，產生 JSON 物件，\n\
                    鍵必須為：Definitions English, Definitions Traditional\n\n\
                    規則：\n\
                    - 唔好加入多餘文字或說明，只輸出 JSON。\n\
                    - Definitions English：必須用英文，而且係詳細嘅釋義或例句。\n\
                    - Definitions Traditional：必須用繁體中文，係 Definitions English 嘅翻譯。\n\
                    - 重要：釋義不可以包含以下繁體中文詞語嘅任何字：'{}'\n\
                    - 釋義必須用不同嘅詞語來解釋意思，或者提供例句。\n\n\
                    繁體中文詞語：{}\n\n\
                    只輸出 JSON。",
                    traditional, traditional
                )
            };

            let ai_json = match self
                .models_clients
                .open_ai_client
                .get_prompt_response(&prompt)
                .await
            {
                Ok(resp) => resp,
                Err(e) => {
                    println!("\n筆記 {} AI 請求失敗：{}", note_id, e);
                    failed_notes += 1;
                    continue;
                }
            };

            // 嘗試解析為 JSON
            let parsed: serde_json::Value = match serde_json::from_str(ai_json.trim()) {
                Ok(v) => v,
                Err(e) => {
                    println!("\n筆記 {} JSON 解析失敗：{}", note_id, e);
                    failed_notes += 1;
                    continue;
                }
            };

            let definitions_english = parsed
                .get("Definitions English")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .trim()
                .to_string();

            let definitions_traditional = parsed
                .get("Definitions Traditional")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .trim()
                .to_string();

            if definitions_english.is_empty() || definitions_traditional.is_empty() {
                println!("\n筆記 {} AI 返回空內容，跳過", note_id);
                skipped_notes += 1;
                continue;
            }

            // 更新筆記
            let mut updates = std::collections::HashMap::new();
            updates.insert(
                ChineseNoteFields::DefinitionsEnglish.as_str().to_string(),
                definitions_english.clone(),
            );
            updates.insert(
                ChineseNoteFields::DefinitionsTraditional
                    .as_str()
                    .to_string(),
                definitions_traditional.clone(),
            );
            // 只有當 Definition 欄位為空時先更新
            let current_definition = note.get_processed_field(ChineseNoteFields::Definition);
            if current_definition.is_none() || current_definition.as_ref().unwrap().is_empty() {
                updates.insert(
                    ChineseNoteFields::Definition.as_str().to_string(),
                    definitions_english.clone(),
                );
            }
            // 清空呢兩個欄位，之後會用其他指令處理
            updates.insert(
                ChineseNoteFields::DefinitionsJyutping.as_str().to_string(),
                String::new(),
            );
            updates.insert(
                ChineseNoteFields::ColorsDefinitionsTraditional
                    .as_str()
                    .to_string(),
                String::new(),
            );

            if self
                .models_clients
                .anki_client
                .update_note_fields(*note_id, updates)
                .await
                .is_err()
            {
                println!("\n筆記 {} 更新失敗", note_id);
                failed_notes += 1;
                continue;
            }

            updated_notes += 1;
        }

        println!("\n\n更新完成：");
        println!("  成功：{}", updated_notes);
        println!("  跳過：{}", skipped_notes);
        println!("  失敗：{}", failed_notes);

        Ok(())
    }

    /// 用更通用嘅方式處理不完整嘅筆記
    ///
    /// 目標：迭代所有不完整嘅筆記（即 `Traditional` 或 `Definition` 缺失，
    /// 實作：用 OpenAI 根據提供嘅兩個欄位產生結構化 JSON，再寫入 Anki。
    pub async fn process_incomplete_notes_generic(
        &'a mut self,
        auto_confirm: bool,
    ) -> Result<(), Box<dyn std::error::Error>> {
        // 目標欄位（由 AI 生成），易於擴充：喺呢度加就得
        const TARGET_FIELDS: &[ChineseNoteFields] = &[
            // 亦要產生呢兩個基本欄位（唔再視為輸入）
            ChineseNoteFields::Traditional,
            ChineseNoteFields::Definition,
            // 其他欄位
            ChineseNoteFields::Simplified,
            ChineseNoteFields::DefinitionsEnglish,
            ChineseNoteFields::DefinitionsTraditional,
            ChineseNoteFields::GrammarType,
        ];

        // 唔好嘥輸出，先計下需要處理嘅數量
        let incomplete_notes = self.get_incomplete_notes();
        if incomplete_notes.is_empty() {
            println!("無需要處理嘅不完整筆記。");
            // 無改動就唔好嘈
            return Ok(());
        }

        let mut updated_notes = 0u64;
        let mut skipped_notes = 0u64;
        let mut failed_notes = 0u64;

        for (idx, note) in incomplete_notes.iter().enumerate() {
            // 組合一個 content 作為輸入來源
            // 備註：而家 `Traditional` 同 `Definition` 都可能係混雜內容，
            //     唔係有效值，所以將佢哋當原始素材，交由 AI 重建欄位。
            let traditional_src = note
                .get_processed_field(ChineseNoteFields::Traditional)
                .unwrap_or_default();
            let definition_src = note
                .get_processed_field(ChineseNoteFields::Definition)
                .unwrap_or_default();
            let content = [traditional_src.as_str(), definition_src.as_str()]
                .iter()
                .filter(|s| !s.is_empty())
                .cloned()
                .collect::<Vec<&str>>()
                .join("\n\n");

            if content.is_empty() {
                // 冇素材就冇得處理
                skipped_notes += 1;
                continue;
            }

            // 喺查詢 AI 之前，再次確認（Enter 視為同意）
            if !auto_confirm {
                println!(
                    "將會用以下原始內容查詢 AI（{}/{}，剩餘 {}）：",
                    idx + 1,
                    incomplete_notes.len(),
                    incomplete_notes.len().saturating_sub(idx + 1)
                );
                println!("  原始內容：\n{}", content);
                println!("  繼續查詢 AI？(Y/n) — 直接 Enter 視為同意");
                let mut ai_input = String::new();
                if std::io::stdin().read_line(&mut ai_input).is_err() {
                    println!("  讀取輸入失敗，已跳過");
                    skipped_notes += 1;
                    continue;
                }
                let ai_trimmed = ai_input.trim();
                let ai_confirm = ai_trimmed.is_empty() || ai_trimmed.eq_ignore_ascii_case("y");
                if !ai_confirm {
                    println!("  已跳過查詢 AI");
                    skipped_notes += 1;
                    continue;
                }
            } else {
                print!("\r處理中：{}/{}", idx + 1, incomplete_notes.len());
                std::io::Write::flush(&mut std::io::stdout()).ok();
            }

            // 構造要求 JSON 輸出嘅提示
            // 要求：只用提供嘅資訊，唔好杜撰；冇就設為空字串。
            // 將目標欄位名連成字串，方便維護
            let target_keys = TARGET_FIELDS
                .iter()
                .map(|f| f.as_str())
                .collect::<Vec<_>>()
                .join(", ");

            let prompt = format!(
                "你係一個粵語同漢字專家。根據以下內容，產生 JSON 物件，\n\
                鍵必須為：\n\n{keys}\n\n\
                規則：\n\
                - 唔好加入多餘文字或說明，只輸出 JSON。\n\
                - 如果資訊不足，該鍵請設為空字串。\n\
                - Definition：必須用英文，而且係簡短嘅定義（brief definition），唔可包含粵拼或繁體。\n\
                - Definitions Traditional：只包含繁體中文內容，唔可包含英文或粵拼。\n\
                - Definitions English：只包含英文內容，必須係 Definitions Traditional 嘅翻譯，唔可包含粵拼或繁體。\n\
                - Simplified：必須係 Traditional 欄位內容嘅簡體中文對應（只包含簡體字）。\n\
                - Grammar type 必須係以下其中一個：{:?}。資訊不足就設為空字串。\n\n\
                內容：\n\
                {}\n\n\
                只輸出 JSON。",
                POSSIBLE_GRAMMAR_TYPES,
                content,
                keys = target_keys
            );

            let ai_json = match self
                .models_clients
                .open_ai_client
                .get_prompt_response(&prompt)
                .await
            {
                Ok(resp) => resp,
                Err(_) => {
                    failed_notes += 1;
                    continue;
                }
            };

            // 嘗試解析為 JSON
            let parsed: serde_json::Value = match serde_json::from_str(ai_json.trim()) {
                Ok(v) => v,
                Err(_) => {
                    // 如果返唔到有效 JSON，就跳過
                    failed_notes += 1;
                    continue;
                }
            };

            // 構造需要更新嘅欄位集合，只更新非空字串
            let mut updates: HashMap<String, String> = HashMap::new();

            // Helper：安全攞字串值
            let get_str = |key: &str| -> String {
                parsed
                    .get(key)
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .trim()
                    .to_string()
            };

            // 通用處理：迭代目標欄位
            for field in TARGET_FIELDS {
                let key = field.as_str();
                let val = get_str(key);
                if val.is_empty() {
                    continue;
                }
                // Grammar type 需要白名單檢查
                if matches!(field, ChineseNoteFields::GrammarType) {
                    if POSSIBLE_GRAMMAR_TYPES.contains(&val.as_str()) {
                        updates.insert(key.to_string(), val);
                    }
                } else {
                    updates.insert(key.to_string(), val);
                }
            }

            if updates.is_empty() {
                skipped_notes += 1;
                continue;
            }

            // 先打印預計更新欄位，問用家確認
            let total = incomplete_notes.len();
            let current_idx = idx + 1;
            let remaining = total.saturating_sub(current_idx);

            if !auto_confirm {
                println!(
                    "準備更新 Note {}（{}/{}，剩餘 {}）：",
                    note.id, current_idx, total, remaining
                );
                // 顯示原始 content，方便人手確認
                println!("  原始內容：\n{}", content);
                println!("  新欄位：");
                let ordered_keys = [
                    ChineseNoteFields::Definition.as_str(),
                    ChineseNoteFields::Traditional.as_str(),
                    ChineseNoteFields::Simplified.as_str(),
                    ChineseNoteFields::GrammarType.as_str(),
                    ChineseNoteFields::DefinitionsTraditional.as_str(),
                    ChineseNoteFields::DefinitionsEnglish.as_str(),
                ];

                let mut printed: std::collections::HashSet<&str> = std::collections::HashSet::new();
                for key in ordered_keys.iter() {
                    if let Some(v) = updates.get(*key) {
                        println!("    {}: {}", key, v);
                        printed.insert(*key);
                    }
                }
                // 其餘未列出嘅欄位（例如 Colors Traditional），保持原樣打印
                for (k, v) in &updates {
                    if printed.contains(k.as_str()) {
                        continue;
                    }
                    println!("    {}: {}", k, v);
                }
                println!("  確認更新？(Y/n) — 直接 Enter 視為同意");

                let mut input = String::new();
                if std::io::stdin().read_line(&mut input).is_err() {
                    println!("  讀取輸入失敗，已跳過");
                    skipped_notes += 1;
                    continue;
                }
                let trimmed = input.trim();
                // 預設同意：空字串或者 'y' 視為 yes
                let confirm = trimmed.is_empty() || trimmed.eq_ignore_ascii_case("y");
                if !confirm {
                    println!("  已跳過");
                    skipped_notes += 1;
                    continue;
                }
            }

            // 寫返去 Anki（已確認）
            if self
                .models_clients
                .anki_client
                .update_note_fields(note.id, updates)
                .await
                .is_err()
            {
                failed_notes += 1;
                continue;
            }

            updated_notes += 1;
        }

        // 執行完再 sync，保持狀態一致
        self.sync().await?;

        // 如果用咗 auto_confirm 模式，最後打印換行
        if auto_confirm && (updated_notes > 0 || failed_notes > 0 || skipped_notes > 0) {
            println!();
        }

        // 輕量輸出結果（有改動先講）
        if updated_notes > 0 || failed_notes > 0 {
            println!(
                "已更新 {} 個筆記；跳過 {}；失敗 {}",
                updated_notes, skipped_notes, failed_notes
            );
        }

        Ok(())
    }

    pub fn get_unique_grammar_types(&'a self) -> Vec<String> {
        let mut grammar_types = Vec::new();

        for note in self.note_id_to_note.values() {
            if let Some(grammar_type) = note.get_processed_field(ChineseNoteFields::GrammarType) {
                if !grammar_types.contains(&grammar_type) {
                    grammar_types.push(grammar_type);
                }
            }
        }

        grammar_types
    }

    /// 將 Traditional 及 Definitions Traditional 每個字按粵拼聲調上色，
    /// 分別寫入 Colors Traditional 同 Colors Definitions Traditional 欄位
    /// 規則：
    /// - 針對所有筆記運行（冇確認），只更新顏色欄位（冇改動就唔更新）
    /// - 必須有對應嘅文本欄位同粵拼欄位
    /// - 粵拼用空格分隔，與目標文本字數一一對應
    /// - 用 tone 尾數決定顏色
    pub async fn add_colors(&'a mut self) -> Result<(), Box<dyn std::error::Error>> {
        let mut processed = 0u64;
        let mut skipped = 0u64;

        for note in self.note_id_to_note.values() {
            // 直接讀取原始顏色欄位（HTML），以便等值比較
            let current_colors_trad = note.get_raw_field(ChineseNoteFields::ColorsTraditional);
            let current_colors_defs =
                note.get_raw_field(ChineseNoteFields::ColorsDefinitionsTraditional);

            // 讀取文本與粵拼來源（已做 HTML 文字抽取）
            let trad_text = note.get_processed_field(ChineseNoteFields::Traditional);
            let trad_jyut = note.get_processed_field(ChineseNoteFields::Jyutping);
            let defs_text = note.get_processed_field(ChineseNoteFields::DefinitionsTraditional);
            let defs_jyut = note.get_processed_field(ChineseNoteFields::DefinitionsJyutping);

            // 聲調顏色對應
            let tone_color = |tone: u8| -> &'static str {
                match tone {
                    1 => "#c0c0c0", // silver
                    2 => "#7ceb95", // green
                    3 => "#fccff9", // pink
                    4 => "#b9d5f4", // blue
                    5 => "#ffb27a", // orange
                    6 => "#b34df7", // purple
                    _ => "#000000", // background
                }
            };

            // 將文字同粵拼轉成彩色 HTML；保留原來嘅標點符號、不上色
            let make_colored = |text: &str, jyut: &str| -> Option<String> {
                let is_han = |c: char| -> bool { matches!(c as u32, 0x4E00..=0x9FFF) };
                // 濾走枚舉及非音節 token（必須含字母且以數字結尾）
                let items: Vec<&str> = jyut
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
                    .collect();
                let mut html = String::new();
                let mut item_idx = 0usize;
                let total_han = text.chars().filter(|c| is_han(*c)).count();
                if items.len() < total_han {
                    return None;
                }
                for ch in text.chars() {
                    if is_han(ch) {
                        let syllable = items[item_idx];
                        item_idx += 1;
                        let tone = syllable
                            .chars()
                            .rev()
                            .find_map(|c| {
                                if c.is_ascii_digit() {
                                    Some(c.to_digit(10).unwrap_or(0) as u8)
                                } else {
                                    None
                                }
                            })
                            .unwrap_or(0);
                        let color = tone_color(tone);
                        html.push_str(&format!("<span style=\"color:{}\">{}</span>", color, ch));
                    } else {
                        // 非漢字（包括標點）原樣保留
                        html.push(ch);
                    }
                }
                Some(html)
            };

            let mut updates: HashMap<String, String> = HashMap::new();

            // Colors Traditional
            if let (Some(t_text), Some(t_jyut)) = (trad_text.as_deref(), trad_jyut.as_deref()) {
                if let Some(new_html) = make_colored(t_text, t_jyut) {
                    if current_colors_trad.as_deref() != Some(new_html.as_str()) {
                        updates.insert(
                            ChineseNoteFields::ColorsTraditional.as_str().to_string(),
                            new_html,
                        );
                    }
                }
            }

            // Colors Definitions Traditional（新需求）
            if let (Some(d_text), Some(d_jyut)) = (defs_text.as_deref(), defs_jyut.as_deref()) {
                if let Some(new_html) = make_colored(d_text, d_jyut) {
                    if current_colors_defs.as_deref() != Some(new_html.as_str()) {
                        updates.insert(
                            ChineseNoteFields::ColorsDefinitionsTraditional
                                .as_str()
                                .to_string(),
                            new_html,
                        );
                    }
                }
            }

            if updates.is_empty() {
                skipped += 1;
                continue;
            }

            // 一次過更新需要變更嘅顏色欄位
            self.models_clients
                .anki_client
                .update_note_fields(note.id, updates)
                .await?;

            processed += 1;
        }

        if processed > 0 {
            println!("已為 {} 個筆記上色；跳過 {}", processed, skipped);
        }

        Ok(())
    }

    pub async fn fill_jyutping(&'a mut self) -> Result<(), Box<dyn std::error::Error>> {
        // 讀取粵拼字典（簡單 YAML）
        let jy_map = JyutpingReader::read_file("converted-list-jy.yml")?;

        let map_text = |text: &str| -> Option<String> {
            let mut out: Vec<String> = Vec::with_capacity(text.chars().count());
            for ch in text.chars() {
                if let Some(j) = jy_map.get(&ch) {
                    out.push(j.clone());
                } else {
                    out.push(ch.to_string());
                }
            }
            Some(out.join(" "))
        };

        let mut updated = 0u64;
        let mut skipped = 0u64;

        for note in self.note_id_to_note.values() {
            // Traditional -> Jyutping
            let mut updates: HashMap<String, String> = HashMap::new();

            if let Some(trad) = note.get_processed_field(ChineseNoteFields::Traditional) {
                if !trad.is_empty() {
                    if let Some(gen) = map_text(&trad) {
                        let current = note.get_processed_field(ChineseNoteFields::Jyutping);
                        if current.as_deref() != Some(gen.as_str()) {
                            updates.insert(ChineseNoteFields::Jyutping.as_str().to_string(), gen);
                        }
                    } else {
                        // 備註：有字搵唔到粵拼，跳過此欄位
                    }
                }
            }

            // Definitions Traditional -> Definitions Jyutping
            if let Some(def_trad) =
                note.get_processed_field(ChineseNoteFields::DefinitionsTraditional)
            {
                if !def_trad.is_empty() {
                    if let Some(gen) = map_text(&def_trad) {
                        let current =
                            note.get_processed_field(ChineseNoteFields::DefinitionsJyutping);
                        if current.as_deref() != Some(gen.as_str()) {
                            updates.insert(
                                ChineseNoteFields::DefinitionsJyutping.as_str().to_string(),
                                gen,
                            );
                        }
                    } else {
                        // 同上：有字冇粵拼 => 跳過此欄位
                    }
                }
            }

            if updates.is_empty() {
                skipped += 1;
                continue;
            }

            // 寫返去 Anki
            if self
                .models_clients
                .anki_client
                .update_note_fields(note.id, updates)
                .await
                .is_err()
            {
                println!("更新 Note {} 粵拼失敗", note.id);
                // 如果單條失敗，當作跳過
                skipped += 1;
                continue;
            }

            updated += 1;
        }

        // 完成後 sync 一次
        self.sync().await?;

        if updated > 0 {
            println!("已填充粵拼 {} 條；跳過 {} 條", updated, skipped);
        }

        Ok(())
    }
}
