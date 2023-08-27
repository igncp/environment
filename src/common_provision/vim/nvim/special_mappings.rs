use crate::base::Context;

use super::{add_special_vim_map_re, install::add_special_vim_map};

pub fn run_nvim_special_mappings(context: &mut Context) {
    add_special_vim_map(
        context,
        [
            "renameexisting",
            r#":Rename <c-r>=expand("%:t")<cr>"#,
            "rename existing file",
        ],
    );
    add_special_vim_map(
        context,
        [
            "showabsolutepath",
            r#":echo expand("%:p")<cr>"#,
            "show absolute path of file",
        ],
    );
    add_special_vim_map(
        context,
        [
            "showrelativepath",
            r#":echo @%<cr>"#,
            "show relative path of file",
        ],
    );

    add_special_vim_map(
        context,
        [
            "addprops",
            r#"_f(li{}: Props <c-c>kitype Props = {<cr>}<c-c>jf}i"#,
            "add props type to function component",
        ],
    );

    add_special_vim_map_re(
        context,
        [
            "translationjsx",
            r#"vitS}lvi}S)lvi)S'hit('<c-c>2lvlc,<c-c>hi"#,
            "translation for jsx content",
        ],
    );

    add_special_vim_map_re(
        context,
        [
            "translationdquotes",
            r#"va"S}lvi}S)it<right>,<left>'"#,
            "translation for prop with double quotes",
        ],
    );

    add_special_vim_map(
        context,
        [
            "cpfat",
            r#":call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr>test\')<cr> "#,
            "ctrlp filename adding test",
        ],
    );

    add_special_vim_map(
        context,
        [
            "cpfrt",
            r#":call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr><bs><bs><bs><bs><bs>\')<cr>"#,
            "ctrlp filename removing test",
        ],
    );

    add_special_vim_map(
        context,
        [
            "ctit",
            r#"? it(<cr>V$%y$%o<cr><c-c>Vpf(2l"#,
            "test copy it test case content",
        ],
    );

    add_special_vim_map(
        context,
        [
            "ctde",
            r#"? describe(<cr>V$%y$%o<cr><c-c>Vpf(2l"#,
            "test copy describe test content",
        ],
    );

    add_special_vim_map(
        context,
        [
            "eeq",
            r#"iXexpectEqual<c-o>:call feedkeys("<c-l>", "t")<cr>"#,
            "test expect toEqual",
        ],
    );

    add_special_vim_map(
        context,
        ["sjsfun", "v/[^,] {<cr><right>%", "select js function"],
    );

    add_special_vim_map(
        context,
        ["djsfun", "v/[^,] {<cr><right>%d", "cut js function"],
    );

    add_special_vim_map(
        context,
        [
            "tjmvs",
            r#"I<c-right><right><c-c>viwy?describe(<cr>olet <c-c>pa;<c-c><c-o><left>v_<del>"#,
            "jest move variable outside of it",
        ],
    );

    add_special_vim_map(
        context,
        [
            "titr",
            r#"_ciwconst<c-c>/from<cr>ciw= require(<del><c-c>$a)<c-c>V:<c-u>%s/\%V\C;//g<cr>"#,
            "transform import to require",
        ],
    );

    add_special_vim_map(
        context,
        ["jimc", "a.mock.calls<c-c>", "jest instert mock calls"],
    );

    add_special_vim_map(
        context,
        [
            "jimi",
            "a.mockImplementation(() => )<left>",
            "jest instert mock implementation",
        ],
    );

    add_special_vim_map(
        context,
        [
            "jirv",
            "a.mockReturnValue()<left>",
            "jest instert mock return value",
        ],
    );

    add_special_vim_map(
        context,
        [
            "ftcrefuntype",
            r#"viwyi<c-right><left>: <c-c>pviwyO<c-c>Otype <c-c>pa = () => <c-c>4hi"#,
            "typescript create function type",
        ],
    );

    add_special_vim_map(
        context,
        [
            "jrct",
            r"gv:<c-u>%s/\%V\C+//ge<cr>:<c-u>%s/\%V\CObject //ge<cr>:<c-u>%s/\%V\CArray //ge<cr>:<c-u>%s/\%V\C\[Fun.*\]/expect.any(Function)/ge<cr>",
            "jest replace copied text from terminal",
        ],
    );
}
