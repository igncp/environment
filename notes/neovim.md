- 崩潰嘅記錄: `:echo stdpath("log")`
    - 例如係 MacOS 入面: `$HOME/.local/state/nvim`
    - 有多個檔案，例如： `find $HOME/.local/state/nvim -type f`
- 特定於以下嘅記錄： `nvim.coc`
    - `NVIM_COC_LOG_LEVEL=debug NVIM_COC_LOG_FILE=/tmp/coc.log nvim foo`: To redirect logs to a file
    - https://github.com/neoclide/coc.nvim/issues/1843#issuecomment-623060834
- nvim 跑時間嘅記錄（佢亦都可以喺 vim 入面運作）
    `nvim -V9myVim.log somefile.txt`
