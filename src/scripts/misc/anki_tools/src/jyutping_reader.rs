use std::{collections::HashMap, fs, io, path::Path};

pub struct JyutpingReader;

impl JyutpingReader {
    /// 從檔案路徑讀取
    pub fn read_file<P: AsRef<Path>>(path: P) -> io::Result<HashMap<char, String>> {
        let content = fs::read_to_string(path)?;
        Ok(Self::parse_from_str(&content))
    }

    fn parse_from_str(s: &str) -> HashMap<char, String> {
        let mut map: HashMap<char, String> = HashMap::new();
        let mut in_dict = false;

        for raw_line in s.lines() {
            // 去除 BOM 同前後空白
            let line = raw_line.trim_start_matches('\u{FEFF}').trim();
            if line.is_empty() {
                continue;
            }

            // 進入 dict 區段
            if !in_dict {
                if line.starts_with("dict:") {
                    in_dict = true;
                }
                continue;
            }

            // 只處理 list 項目行：「- 字  粵拼  [百分比]」
            if !line.starts_with('-') {
                // 一旦離開 list（遇到其他內容），就可以結束
                // 但為簡化，繼續掃描都冇壞處
                continue;
            }

            // 移除開頭 dash
            let after_dash = line.trim_start_matches('-').trim_start();
            if after_dash.is_empty() {
                continue;
            }

            // 第一個字元係漢字（或其他單一字元）
            let mut chars = after_dash.chars();
            let ch = match chars.next() {
                Some(c) => c,
                None => continue,
            };

            // 後面應該至少有一個空白跟住粵拼 token
            let rest = chars.as_str().trim_start();
            if rest.is_empty() {
                continue;
            }

            // 粵拼 token：連續英文字母，尾部跟 1-6
            // 唔用 regex，逐字掃
            let mut jy_end = 0usize;
            for (i, c) in rest.char_indices() {
                if c.is_ascii_whitespace() {
                    jy_end = i;
                    break;
                }
            }
            let jy = if jy_end == 0 {
                // 行內冇再出現空白，即粵拼直到行尾
                rest
            } else {
                &rest[..jy_end]
            };

            if jy.is_empty() {
                continue;
            }

            // 基本驗證：最後一位係數字（聲調 1-6）
            if !matches!(jy.chars().last(), Some(d) if d.is_ascii_digit()) {
                continue;
            }

            // 寫入映射；重覆鍵以後者覆蓋
            map.insert(ch, jy.to_string());
        }

        map
    }
}

#[cfg(test)]
mod tests {
    use super::JyutpingReader;
    use std::collections::HashMap;

    #[test]
    fn parse_sample() {
        let input = r#"
dict:
  - 吖  a1      3%
  - 啊  a3      0%
  - 㝞  aa1
  - 䃁  aa1
  - 丫  aa1
  - 厊  aa1
  - 吖  aa1
  - 啞  aa1     3%
"#;

        let map = JyutpingReader::parse_from_str(input);
        let mut expected: HashMap<char, &str> = HashMap::new();
        expected.insert('吖', "aa1"); // 後者覆蓋前者
        expected.insert('啊', "a3");
        expected.insert('㝞', "aa1");
        expected.insert('䃁', "aa1");
        expected.insert('丫', "aa1");
        expected.insert('厊', "aa1");
        expected.insert('啞', "aa1");

        for (k, v) in expected {
            assert_eq!(map.get(&k).map(|s| s.as_str()), Some(v));
        }
    }
}
