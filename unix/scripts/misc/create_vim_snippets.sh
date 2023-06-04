#!/usr/bin/env bash

set -e

mkdir -p ~/.vim-snippets

cat >> ~/.bash_aliases <<"EOF"
alias ModifySnippets='"$EDITOR" ~/development/environment/unix/scripts/misc/create_vim_snippets.sh && sh ~/development/environment/unix/scripts/misc/create_vim_snippets.sh'
EOF

cat > ~/.vim-snippets/javascript.snippets <<"EOF"
snippet ide
if (${0}) {
  debugger;
}
endsnippet

snippet ck
  console.log("${0:}", $0);
endsnippet

snippet cj
  console.log("LOG POINT - ${0:}");
endsnippet

snippet des
  describe("${1:}", () => {
    it("${2:}", () => {
      ${0}
    });
  });
endsnippet

snippet xBeforeEach
beforeEach(() => {
  ${0}
});
endsnippet

snippet xAfterEach
afterEach(() => {
  ${0}
});
endsnippet

snippet it
it("${1:}", () => {
  ${0}
});
endsnippet

snippet exp
expect(${1:}).to${0};
endsnippet

snippet t
<${1}>${2}</$1>
endsnippet

snippet T
<${1} ${2}/>
endsnippet

snippet TT
<${1}
/>
endsnippet

snippet tt
<${1}
>
  ${2}
</$1>
endsnippet

snippet xExpectToEqual
expect(${1}).toEqual(${0});
endsnippet

snippet xExpectJustCallsToEqual
expect(${1}.mock.calls).toEqual([${0}])
endsnippet

snippet >
(${1}) => ${2:null}${0}
endsnippet

snippet xJestJustMock
jest.mock("${0}")
endsnippet

snippet xJestMockWithVariable
const mock$2 = {
  ${0}: jest.fn(),
}
jest.mock("${1}", () => mock${2})
endsnippet

snippet xJestSpyOn
jest.spyOn(${1}, "${2}")
endsnippet

snippet xConstJustRequire
const ${1} = require("${0}$1")
endsnippet

snippet xConstRequireDestructuring
const {
  ${1},
} = require("${0}")
endsnippet

snippet xJestMockImplementation
${1}.mockImplementation(() => ${0})
endsnippet

snippet xJestMockReturnValue
${1}.mockReturnValue(${0})
endsnippet

snippet xIstanbulIgnoreElse
// istanbul ignore else
endsnippet

snippet xEnzymeShallowWrapper
const wrapper = shallow(
  <${0} />
)
endsnippet

snippet xExpectEnzymeFindLength
expect(${1:wrapper}.find(${2})).toHaveLength(${0:1});
endsnippet

snippet xJestFnRaw
jest.fn(${0})
endsnippet

snippet xJestFnConst
const ${1} = jest.fn(${0})
endsnippet

snippet xJestFnProperty
${1}: jest.fn(${0}),
endsnippet

snippet xJestFnExisting
${1} = jest.fn(${0})
endsnippet

snippet xReactSetState
${1: this}.setState({
  ${2}: ${0},
})
endsnippet

snippet i
import ${1} from "${0}"
endsnippet

snippet ii
import {
  ${1},
} from "${0}"
endsnippet

snippet xConstObjEqual
const ${1} = {
  ${2}: ${0},
}
endsnippet

snippet xItSentenceFunctions
calls ${1:the expected functions}${2: when}${3}
endsnippet

snippet xItSentenceReturn
returns ${1:the expected result}${2: when}${3}
endsnippet

snippet xItSentenceSnapshot
matches the snapshot ${2: when}${3}
endsnippet

snippet xJestMockComponent
const mock$2 = () => null;

jest.mock("../${1}", () => mock${2});
endsnippet

snippet xExpectToContain
expect(${1}).toContain(${0});
endsnippet

snippet xLogOnce
if (!console.info.${1:logged} && ${2:true}) {
  console.info.$1 = true;
  ${3:console.info('logged')};
}
endsnippet

snippet xReactNewComponent
import React from 'react';
import PropTypes from 'prop-types';

const ${1} = ({ children }) => {
  return ${0}<div>{children}</div>
};

$1.propTypes = {
  children: PropTypes.node
};

$1.defaultProps = {};

export default $1;
endsnippet

snippet => "Arrow function" i
() => {
  ${0}
}
endsnippet
EOF

cp ~/.vim-snippets/javascript.snippets ~/.vim-snippets/typescript.snippets
cp ~/.vim-snippets/javascript.snippets ~/.vim-snippets/typescriptreact.snippets

cat > ~/.vim-snippets/markdown.snippets <<"EOF"
snippet xBoldColon
**${1}**: ${0}
endsnippet

snippet c
[ ] ${0}
endsnippet

snippet cx
[X] ${0}
endsnippet

snippet xNewIssue
- TICKET
- Branch: \`BRANCH\`

# Research

# Misc

# Conclusion

# TODO

- [ ] Replicate
- [ ] Find reason
- [ ] Fix
- [ ] Refactor
- [ ] Others: Tests, Docs
endsnippet
EOF

# https://misc.flogisoft.com/bash/tip_colors_and_formatting
cat > ~/.vim-snippets/sh.snippets <<"EOF"
snippet xColorBlue
COLOR_BLUE="\e[34m"
endsnippet

snippet xColorGreen
COLOR_GREEN="\e[32m"
endsnippet

snippet xColorRed
COLOR_RED="\e[31m"
endsnippet

snippet xColorReset
COLOR_RESET="\e[0m"
endsnippet
EOF

cat > ~/.vim-snippets/rust.snippets <<"EOF"
snippet xDeadCode
#[allow(dead_code)]
endsnippet

snippet xNowInstant
let ${0:now} = std::time::Instant::now();
endsnippet

snippet xPrintInstant
println!("${1}{:?}", ${0:now}.elapsed());
endsnippet

snippet xModTests
#[cfg(test)]
mod tests {
  use super::*;

  ${0}
}
endsnippet

snippet xAssertEq
assert_eq!(${1}, ${0});
endsnippet

snippet xPrintEmpty
println!();
endsnippet
EOF

# header files are treated as cpp
cat > /tmp/c-and-cpp-snippets <<"EOF"
snippet xDefineGuard
#ifndef ${1}_H
#define $1_H

${0}

#endif
endsnippet
EOF
cp /tmp/c-and-cpp-snippets ~/.vim-snippets/c.snippets
cp /tmp/c-and-cpp-snippets ~/.vim-snippets/cpp.snippets

cat > ~/.vim-snippets/php.snippets <<"EOF"
snippet xLogStdOut
// LOG ---
\$new_log_abc = fopen('php://stdout', 'w'); fputs(\$new_log_abc, "\n${0}\n\n");
fclose(\$new_log_abc);
// LOG ---

endsnippet

snippet xVarDumpPre
// VAR DUMP ---
echo '<pre>';
var_dump(${0});
echo '</pre>';
// VAR DUMP ---

endsnippet
EOF

if [ ! -f ~/development/environment/project/custom_create_vim_snippets.sh ]; then
  touch ~/development/environment/project/custom_create_vim_snippets.sh
fi

sh ~/development/environment/project/custom_create_vim_snippets.sh
