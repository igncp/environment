# CLI Tools

These are some notes about new found ways to use CLI tools. When used for a
while and learnt they would be remove from here.

## `dasel`

- Convert from json to yml: `cat FILE  | dasel -r json -w yaml`

## `etcdctl`

- Save a snapshot: `etcdctl snapshot save snapshot.db`
    - More info: https://etcd.io/docs/v3.3/op-guide/recovery/
- Print all keys: `etcdctl get "" --prefix --keys-only`

## `dust`

- Used in similar cases of  `du` and `ncdu`, although it doesn't seem to have an interactive mode
- Show the size grouped by the file type: `dust -t .`

## `entr`

- Run command clearing the screen: `echo /tmp/foo.sql | PAGER='' PGPASSWORD=postgres entr -c psql -h 0.0.0.0 -U postgres -d postgres -f /_`
- For waiting until the first change on the file use: `-p`

## `git`

- 查看文件中特定行的歷史: `git log -L num,num:file/path`
- 查看特定提交時文件中特定行的歷史: `git log <commit> -L num,num:file/path`
- 查看特定提交時文件的內容: `git show <commit>:file/path | less -N`

## `kafka`

- 列出主題: `kafka-topics --bootstrap-server http://localhost:9092 --list`
- 描述一個主題: `kafka-topics --bootstrap-server http://localhost:9092 --describe --topic TOPIC_NAME`

## `psql`

- To output in a CSV format can use the `--csv` flag
- To not print the columns headers can pass the `-t` command
- Describe a table (including indexes): `\d+ TABLE_NAME` (`\dt` lists tables)

## `tmux`

- `Prefix` 係預設嘅 `Ctrl-b`。撳 `Prefix + ?` 可以睇晒目前載入咗嘅快捷鍵；`Prefix + :` 可以直接行 tmux 指令。
- 開窗同窗格：`Prefix + c` 喺目前路徑開新視窗；`Prefix + "` 上下分割；`Prefix + %` 左右分割；`Prefix + Space` 循環改變兩個窗格嘅 layout；`Prefix + 方向鍵` 轉焦點；`Prefix + z` 放大／還原目前窗格。
- 管理窗格：`Prefix + x` 關閉目前窗格；`Prefix + !` 將目前窗格搬去新視窗；`Prefix + o` 會提示將另一個窗格搬入目前視窗；`Prefix + u` 會提示將目前窗格搬去目標視窗。
- 交換窗格：`Prefix + {` 向上交換目前窗格；`Prefix + }` 向下交換。目前設定亦會喺 `}` 後揀返左邊窗格。
- 視窗同 session：`Prefix + n` 跳去 `notes:0`；`Prefix + Shift-Left`／`Shift-Right` 交換目前視窗次序；`Prefix + s` 開 session 樹；`Prefix + w` 開視窗樹；`Prefix + d` detach。
- `Prefix + b` 用 `fzf` 揀任何 session 嘅視窗；`Prefix + v` 開 project 預設目標嘅單鍵跳轉選單。後者要先跑 bootstrap，佢會建立 `/tmp/tmux_jump_window.sh`。
- 按百分比設定窗格闊度：`Prefix + :`，然後輸入 `resize-pane -x 30%`。
- 改視窗名：`Prefix + ,`，或者用 `rename-window NAME`。
- 改 session 名：`Prefix + $`，或者用 `rename-session -t SESSION -n NAME`。
- 複製模式：`Prefix + [` 進入；用 `v` 開始選取、`Ctrl-v` 切去矩形選取、`V` 選整行、`y` 複製、`q` 離開；`Prefix + ]` 貼上。撳 `W` 會揀游標底下嘅完整字。
- `tmux-copycat`：`Prefix + /` 做 regex 搜尋；`Prefix + Ctrl-f` 搵檔案路徑；`Ctrl-g` 搵 `git status` 入面嘅檔案；`Ctrl-u` 搵 URL。
- `tmux-clippy`：複製模式入面，將游標放喺 URL 或檔案路徑上，撳 `o` 用系統預設程式開；撳 `Ctrl-o` 用 Neovim 開檔案；撳 `c` 複製偵測到嘅 URL 或路徑。
- `tmux-fingers`：`Prefix + F` 進入 fingers 模式，跟畫面提示嘅按鍵複製偵測到嘅路徑、SHA 或數字。
- `tmux-sessionist`：`Prefix + g` 用名稱揀 session；`Prefix + Shift-s` 回到上一個 session；`Prefix + Shift-c` 建新 session；`Prefix + Shift-x` 關閉目前 session；`Prefix + @` 將目前窗格升做新 session。

## `pstree`

- It can check a string, for example: `pstree -s node`
