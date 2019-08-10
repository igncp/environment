#!/usr/bin/env bash

set -e

mkdir -p ~/.vim-snippets

# this snippets will not be overriden by the provision
# they should be changed manually
mkdir -p /project/vim-custom-snippets/

cat >> ~/.bash_aliases <<"EOF"
alias ModifySnippets='"$EDITOR" /project/provision/create_vim_snippets.sh && sh /project/provision/create_vim_snippets.sh'
EOF

cat > ~/.vim-snippets/javascript.snippets <<"EOF"
snippet ide
  if (${0}) {
    debugger;
  }
snippet ck
  console.log("${0:}", $0);
snippet cj
  console.log("LOG POINT - ${0:}");
snippet des
  describe("${1:}", () => {
    it("${2:}", () => {
      ${0}
    });
  });
snippet xBeforeEach
  beforeEach(() => {
    ${0}
  });
snippet xAfterEach
  afterEach(() => {
    ${0}
  });
snippet it
  it("${1:}", () => {
    ${0}
  });
snippet exp
  expect(${1:}).to${0};
snippet t
  <${1}>${2}</$1>
snippet T
  <${1} ${2}/>
snippet TT
  <${1}
  />
snippet tt
  <${1}
  >
    ${2}
  </$1>
snippet xExpectToEqual
  expect(${1}).toEqual(${0});
snippet xExpectJustCallsToEqual
  expect(${1}.mock.calls).toEqual([${0}])
snippet >
  (${1}) => ${2:null}${0}
snippet xJestJustMock
  jest.mock("${0}")
snippet xJestMockWithVariable
  const mock$2 = {
    ${0}: jest.fn(),
  }
  jest.mock("${1}", () => mock${2})
snippet xJestSpyOn
  jest.spyOn(${1}, "${2}")
snippet xConstJustRequire
  const ${1} = require("${0}$1")
snippet xConstRequireDestructuring
  const {
    ${1},
  } = require("${0}")
snippet xJestMockImplementation
  ${1}.mockImplementation(() => ${0})
snippet xJestMockReturnValue
  ${1}.mockReturnValue(${0})
snippet xIstanbulIgnoreElse
   // istanbul ignore else
snippet xEnzymeShallowWrapper
  const wrapper = shallow(
    <${0} />
  )
snippet xExpectEnzymeFindLength
  expect(${1:wrapper}.find(${2})).toHaveLength(${0:1});
snippet xJestFnRaw
  jest.fn(${0})
snippet xJestFnConst
  const ${1} = jest.fn(${0})
snippet xJestFnProperty
  ${1}: jest.fn(${0}),
snippet xJestFnExisting
  ${1} = jest.fn(${0})
snippet xReactSetState
  ${1: this}.setState({
    ${2}: ${0},
  })
snippet i
  import ${1} from "${0}"
snippet ii
  import {
    ${1},
  } from "${0}"
snippet xConstObjEqual
  const ${1} = {
    ${2}: ${0},
  }
snippet xItSentenceFunctions
  calls ${1:the expected functions}${2: when}${3}
snippet xItSentenceReturn
  returns ${1:the expected result}${2: when}${3}
snippet xItSentenceSnapshot
  matches the snapshot ${2: when}${3}
snippet xJestMockComponent
  const mock$2 = () => null;

  jest.mock("../${1}", () => mock${2});
snippet xExpectToContain
  expect(${1}).toContain(${0});
snippet xLogOnce
  if (!console.info.${1:logged} && ${2:true}) {
    console.info.$1 = true;
    ${3:console.info('logged')};
  }
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
EOF

cp ~/.vim-snippets/javascript.snippets ~/.vim-snippets/typescript.snippets

cat >> ~/.vim-snippets/javascript.snippets <<"EOF"
snippet XimportType
  import type { ${1} } from '${0}';
snippet XflowComment
  // @flow
  ${0}
EOF

cat > ~/.vim-snippets/markdown.snippets <<"EOF"
snippet xBoldColon
  **${1}**: ${0}
EOF

# https://misc.flogisoft.com/bash/tip_colors_and_formatting
cat > ~/.vim-snippets/sh.snippets <<"EOF"
snippet xColorBlue
  COLOR_BLUE="\e[34m"
snippet xColorGreen
  COLOR_GREEN="\e[32m"
snippet xColorRed
  COLOR_RED="\e[31m"
snippet xColorReset
  COLOR_RESET="\e[0m"
EOF

cat > ~/.vim-snippets/rust.snippets <<"EOF"
snippet xDeadCode
  #[allow(dead_code)]
snippet xNowInstant
  let ${0:now} = std::time::Instant::now();
snippet xPrintInstant
  println!("${1}{:?}", ${0:now}.elapsed());
snippet xModTests
  #[cfg(test)]
  mod tests {
    use super::*;

    ${0}
  }
snippet xAssertEq
  assert_eq!(${1}, ${0});
snippet xPrintEmpty
  println!();
EOF

# header files are treated as cpp
cat > /tmp/c-and-cpp-snippets <<"EOF"
snippet xDefineGuard
  #ifndef ${1}_H
  #define $1_H

  ${0}

  #endif
EOF
cp /tmp/c-and-cpp-snippets ~/.vim-snippets/c.snippets
cp /tmp/c-and-cpp-snippets ~/.vim-snippets/cpp.snippets
