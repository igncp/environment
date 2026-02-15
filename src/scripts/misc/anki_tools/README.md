# Anki 工具

呢個係一個用嚟管理同處理 Anki 牌組嘅命令行工具，特別針對粵語學習卡片。

## 前置要求

- 安裝 Anki
- 安裝 [AnkiConnect](https://ankiweb.net/shared/info/2055492159) 插件
- 設定環境變數：
  - 複製 `.env.example` 到 `.env`：`cp .env.example .env`
  - `OPENAI_API`：OpenAI API 金鑰（如果要用 AI 功能）
  - `DEFAULT_DECK_NAME`：預設牌組名稱（可選）

## 安裝

```bash
cargo build --release
```

## 環境變數設定

### DEFAULT_DECK_NAME（可選）

設定預設牌組名稱後，所有需要指定牌組嘅命令都可以唔提供牌組名稱參數，會自動使用環境變數嘅值。

**設定方法：**

喺 `.env` 文件入面加入：
```bash
DEFAULT_DECK_NAME=粵語詞彙
```

**使用示例：**

設定咗 `DEFAULT_DECK_NAME` 之後：
```bash
# 唔使指定牌組名稱
anki_tools analyze-deck
anki_tools add-colors
anki_tools fill-jyutping
```

等同於：
```bash
# 明確指定牌組名稱
anki_tools analyze-deck "粵語詞彙"
anki_tools add-colors "粵語詞彙"
anki_tools fill-jyutping "粵語詞彙"
```

**注意：**
- 如果同時設定咗環境變數同提供咗命令行參數，會優先使用命令行參數
- 如果兩者都冇提供，命令會報錯並要求提供牌組名稱

## 命令

### list-decks

列出所有可用嘅牌組。

**用法：**
```bash
anki_tools list-decks
```

**功能：**
- 顯示 Anki 入面所有牌組嘅名稱
- 方便確認牌組名稱，用於其他命令

**輸出示例：**
```
可用嘅牌組：
- 粵語詞彙
- 英文單詞
- Default
```

---

### analyze-deck

分析牌組嘅統計資料，檢查數據質量。

**用法：**
```bash
anki_tools analyze-deck [牌組名稱] [選項]
```

**參數：**
- `[牌組名稱]`：可選，如果冇提供會使用 `DEFAULT_DECK_NAME` 環境變數

**選項：**
- `-f, --inspect-fields`：檢查欄位，搵出有問題嘅筆記

**功能：**
- 顯示筆記同卡片嘅總數
- 檢查重複嘅傳統文字欄位
- 如果加咗 `-f` 選項：
  - 搵出傳統文字出現喺描述入面嘅筆記
  - 搵出英文釋義同繁體/粵拼相同嘅筆記
  - 提供選項用 AI 生成新釋義

**輸出示例：**
```
牌組分析：粵語詞彙
筆記總數：1523
卡片總數：3046

檢查重複嘅 Traditional 欄位...
搵到 2 組重複嘅 Traditional 欄位
```

---

### process-incomplete-fields

處理缺少語法類型嘅筆記，自動補充欄位。

**用法：**
```bash
anki_tools process-incomplete-fields [牌組名稱] [選項]
```

**參數：**
- `[牌組名稱]`：可選，如果冇提供會使用 `DEFAULT_DECK_NAME` 環境變數

**選項：**
- `-y, --yes`：自動確認所有操作，唔會提示確認

**功能：**
- 搵出缺少語法類型（GrammarType）欄位嘅筆記
- 使用 AI 分析繁體文字，自動填入適合嘅語法類型
- 更新筆記資料

**適用場景：**
- 批量匯入新卡片之後
- 發現某啲筆記缺少語法分類
- 需要統一整理牌組結構

---

### add-colors

為筆記加入顏色標記，根據粵拼聲調上色。

**用法：**
```bash
anki_tools add-colors [牌組名稱]
```

**參數：**
- `[牌組名稱]`：可選，如果冇提供會使用 `DEFAULT_DECK_NAME` 環境變數

**功能：**
- 讀取筆記嘅粵拼欄位
- 根據粵語九聲聲調，為每個字加上對應顏色
- 更新到「傳統文字顏色」欄位
- 方便視覺化學習聲調

**聲調顏色對應：**
- 第一聲：藍色
- 第二聲：綠色
- 第三聲：紅色
- 第四聲：紫色
- 第五聲：橙色
- 第六聲：黃色

**注意事項：**
- 需要筆記已經有粵拼欄位
- 會覆蓋現有嘅顏色標記

---

### fill-jyutping

為缺少粵拼嘅筆記自動填入粵拼。

**用法：**
```bash
anki_tools fill-jyutping [牌組名稱]
```

**參數：**
- `[牌組名稱]`：可選，如果冇提供會使用 `DEFAULT_DECK_NAME` 環境變數

**功能：**
- 搵出粵拼欄位為空嘅筆記
- 從本地粵拼數據庫讀取對應嘅粵拼
- 自動填入到筆記嘅粵拼欄位
- 支援多字詞組嘅粵拼查詢

**數據來源：**
- 使用本地粵拼詞典文件
- 支援常用粵語詞彙同字符

**適用場景：**
- 新增咗筆記但未加粵拼
- 批量補充粵拼資料
- 整理舊有卡片

---

### export-deck

導出牌組到本地文件（.apkg 格式）。

**用法：**
```bash
anki_tools export-deck [牌組名稱] [選項]
```

**參數：**
- `[牌組名稱]`：可選，如果冇提供會使用 `DEFAULT_DECK_NAME` 環境變數

**選項：**
- `-o, --output <路徑>`：指定輸出文件路徑（預設係當前目錄）
- `-s, --schedule`：包含學習進度（複習記錄、到期日期等）

**功能：**
- 將指定牌組導出成 .apkg 文件
- 可選擇係咪包含學習進度
- 方便備份同分享牌組

**輸出示例：**
```bash
# 導出到當前目錄，唔包含學習進度
anki_tools export-deck "粵語詞彙"

# 導出到指定路徑，包含學習進度
anki_tools export-deck "粵語詞彙" -o ~/backups/cantonese.apkg -s
```

**注意事項：**
- 輸出路徑會自動轉換為絕對路徑
- 如果唔指定輸出路徑，會用 `<牌組名稱>.apkg` 做文件名

---

## 常見用法示例

### 基本工作流程

1. **列出所有牌組**
   ```bash
   anki_tools list-decks
   ```

2. **分析牌組質量**
   ```bash
   anki_tools analyze-deck "粵語詞彙" -f
   ```

3. **補充缺少嘅粵拼**
   ```bash
   anki_tools fill-jyutping "粵語詞彙"
   ```

4. **加入聲調顏色**
   ```bash
   anki_tools add-colors "粵語詞彙"
   ```

5. **處理缺少語法類型嘅筆記**
   ```bash
   anki_tools process-incomplete-fields "粵語詞彙" -y
   ```

6. **導出牌組備份**
   ```bash
   anki_tools export-deck "粵語詞彙" -s
   ```

### 批量處理新卡片

匯入新卡片之後，可以用以下順序處理：

```bash
# 如果設定咗 DEFAULT_DECK_NAME 環境變數，可以簡化命令：

# 1. 填入粵拼
anki_tools fill-jyutping

# 2. 加入顏色標記
anki_tools add-colors

# 3. 補充語法類型
anki_tools process-incomplete-fields -y

# 4. 檢查最終質量
anki_tools analyze-deck -f
```

或者明確指定牌組名稱：

```bash
# 1. 填入粵拼
anki_tools fill-jyutping "粵語詞彙"

# 2. 加入顏色標記
anki_tools add-colors "粵語詞彙"

# 3. 補充語法類型
anki_tools process-incomplete-fields "粵語詞彙" -y

# 4. 檢查最終質量
anki_tools analyze-deck "粵語詞彙" -f
```

## 開發

### 檢查代碼質量

使用 `check.sh` 腳本一次過運行格式化、檢查同測試：

```bash
./check.sh
```

呢個腳本會執行：
- 代碼格式化（`cargo fmt`）
- 代碼檢查（`cargo clippy`）
- 運行測試（`cargo test`）

## 疑難排解

### AnkiConnect 連接失敗

- 確認 Anki 已經運行
- 確認 AnkiConnect 插件已安裝同啟用
- 檢查防火牆設定，確保 `localhost:8765` 可以訪問

### AI 功能唔work

- 檢查 `.env` 文件係咪有設定 `OPENAI_API_KEY`
- 確認 API 金鑰有效同有足夠額度

### 粵拼搵唔到

- 確認 `converted-list-jy.yml` 文件存在
- 檢查文件格式係咪正確
- 某啲罕見字可能冇收錄喺詞典入面

## 授權

呢個項目係開源軟件，歡迎貢獻同使用。
