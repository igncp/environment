import importPlugin from 'eslint-plugin-import';
import perfectionist from 'eslint-plugin-perfectionist';
import prettier from 'eslint-plugin-prettier';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import jest from 'eslint-plugin-jest';
import tseslint from 'typescript-eslint';

import eslint from '@eslint/js';
import stylistic from '@stylistic/eslint-plugin';

const paddingLineBetweenStatements = [
  'error',
  { blankLine: 'always', next: 'return', prev: '*' },
]
  .concat(
    [
      'multiline-block-like',
      'multiline-expression',
      'multiline-const',
      'const',
      'type',
      'interface',
      'if',
    ]
      .map((item) => [
        { blankLine: 'always', next: '*', prev: item },
        { blankLine: 'always', next: item, prev: '*' },
      ])
      .flat(),
  )
  .concat([
    {
      blankLine: 'any',
      next: ['singleline-const'],
      prev: ['singleline-const'],
    },
  ]);

const tsRules = {
  '@typescript-eslint/array-type': [2, { default: 'array-simple' }],
  '@typescript-eslint/explicit-member-accessibility': 2,
  '@typescript-eslint/method-signature-style': 2,
  '@typescript-eslint/no-confusing-non-null-assertion': 2,
  '@typescript-eslint/no-explicit-any': 2,
  '@typescript-eslint/no-redeclare': 2,
  '@typescript-eslint/no-shadow': 2,
  '@typescript-eslint/no-unnecessary-boolean-literal-compare': 2,
  '@typescript-eslint/no-unnecessary-condition': [
    2,
    { allowConstantLoopConditions: true },
  ],
  '@typescript-eslint/no-unnecessary-qualifier': 2,
  '@typescript-eslint/no-unnecessary-type-arguments': 2,
  '@typescript-eslint/no-unnecessary-type-assertion': 2,
  '@typescript-eslint/no-unnecessary-type-constraint': 2,
  '@typescript-eslint/no-unused-expressions': 0, // e.g. for react hooks
  '@typescript-eslint/no-unused-vars': [
    'error',
    {
      varsIgnorePattern: '^_',
      ignoreRestSiblings: true,
    },
  ],
  '@typescript-eslint/no-use-before-define': [
    2,
    {
      enums: true,
      ignoreTypeReferences: false,
      typedefs: true,
    },
  ],
  '@typescript-eslint/no-useless-constructor': 2,
  '@typescript-eslint/prefer-includes': 2,
  '@typescript-eslint/prefer-nullish-coalescing': 2,
  '@typescript-eslint/prefer-optional-chain': 2,
  '@typescript-eslint/prefer-readonly': 2,
  '@typescript-eslint/prefer-reduce-type-parameter': 2,
  '@typescript-eslint/prefer-return-this-type': 2,
  '@typescript-eslint/prefer-ts-expect-error': 2,
  '@typescript-eslint/switch-exhaustiveness-check': 2,
  '@typescript-eslint/unified-signatures': 2,
};

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    ignores: ['eslint.config.mjs'],
  },
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
  {
    plugins: {
      perfectionist,
      react,
      'react-hooks': reactHooks,
      stylistic,
      'import': importPlugin,
      jest,
      prettier,
    },
    rules: {
      ...tsRules,
      'arrow-body-style': 'error',

      'import/consistent-type-specifier-style': 'error',
      'import/exports-last': 'error',
      'import/no-duplicates': 'error',
      'import/no-useless-path-segments': 'error',

      'jest/no-disabled-tests': 'error',
      'jest/no-focused-tests': 'error',
      'jest/no-identical-title': 'error',
      'jest/prefer-to-have-length': 'error',
      'jest/valid-expect': 'error',

      'no-console': ['error', { allow: ['warn', 'error'] }],

      'perfectionist/sort-array-includes': 'error',
      'perfectionist/sort-astro-attributes': 'error',
      'perfectionist/sort-classes': 'error',
      'perfectionist/sort-enums': 'error',
      'perfectionist/sort-exports': 'error',
      'perfectionist/sort-imports': 'error',
      'perfectionist/sort-interfaces': 'error',
      'perfectionist/sort-intersection-types': 'error',
      'perfectionist/sort-jsx-props': 'error',
      'perfectionist/sort-maps': 'error',
      'perfectionist/sort-named-exports': 'error',
      'perfectionist/sort-named-imports': 'error',
      'perfectionist/sort-object-types': 'error',
      'perfectionist/sort-objects': 'error',
      'perfectionist/sort-sets': 'error',
      'perfectionist/sort-svelte-attributes': 'error',
      'perfectionist/sort-switch-case': 'error',
      'perfectionist/sort-union-types': 'error',
      'perfectionist/sort-variable-declarations': 'error',
      'perfectionist/sort-vue-attributes': 'error',

      'prefer-const': 'error',
      'prefer-destructuring': ['error'],
      'prefer-spread': 'error',
      'prefer-template': 'error',

      'prettier/prettier': 'error',

      'quote-props': ['error', 'consistent-as-needed'],

      'react-hooks/exhaustive-deps': 'error',
      'react-hooks/rules-of-hooks': 'error',

      'react/destructuring-assignment': [
        'error',
        'always',
        { destructureInSignature: 'always' },
      ],
      'react/display-name': 'off',
      'react/function-component-definition': 'off',
      'react/jsx-boolean-value': 'error',
      'react/jsx-curly-brace-presence': 'error',
      'react/jsx-filename-extension': 'off',
      'react/jsx-fragments': 'error',
      'react/jsx-key': ['error', { warnOnDuplicates: true }],
      'react/jsx-no-useless-fragment': 'error',
      'react/jsx-one-expression-per-line': 'off',
      'react/jsx-props-no-spreading': 'off',
      'react/jsx-sort-props': 'error',
      'react/no-array-index-key': 'off',
      'react/no-unescaped-entities': 'off',
      'react/no-unknown-property': 'off',
      'react/no-unstable-nested-components': 'error',
      'react/no-unused-prop-types': 'error',
      'react/react-in-jsx-scope': 'off',
      'react/require-default-props': 'off',
      'react/self-closing-comp': 'error',

      'semi': ['error', 'always'],

      'stylistic/arrow-parens': ['error', 'always'],
      'stylistic/padding-line-between-statements': paddingLineBetweenStatements,
    },

    settings: {
      'import/resolver': {
        alias: {
          extensions: ['.ts', '.tsx', '.js', '.jsx', '.json'],
          map: [['#', './src/']],
        },
      },
      'react': {
        version: 'detect',
      },
    },
  },
  {
    files: ['**/*.js'],
    rules: {
      '@typescript-eslint/no-var-requires': 0,
      'no-console': 0,
    },
  },
  {
    env: {
      node: true,
    },
    files: ['webpack.config.mjs'],
  },
  {
    files: ['**/*.{ts,tsx,js}'],
    rules: {
      '@typescript-eslint/camelcase': 0,
      '@typescript-eslint/class-name-casing': 0,
      '@typescript-eslint/explicit-function-return-type': 0,
      '@typescript-eslint/explicit-module-boundary-types': 0,
      '@typescript-eslint/member-delimiter-style': 0,
      '@typescript-eslint/no-empty-function': 0,
      '@typescript-eslint/no-non-null-assertion': 0,

      'require-atomic-updates': 0,
    },
  },
  {
    files: ['**/__tests__/*'],
    rules: {
      '@typescript-eslint/no-explicit-any': 0,
    },
  },
);
