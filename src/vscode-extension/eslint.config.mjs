import config from "./node_modules/@igncp/common-config/eslint.config.mjs";

export default config.concat([
  {
    rules: {
      "@typescript-eslint/explicit-member-accessibility": "off",
      "@typescript-eslint/no-unnecessary-condition": "off",
      "@typescript-eslint/no-unsafe-argument": "off",
      "@typescript-eslint/no-unsafe-assignment": "off",
      "@typescript-eslint/no-unsafe-call": "off",
      "@typescript-eslint/no-unsafe-member-access": "off",
      "@typescript-eslint/no-unsafe-return": "off",
      "@typescript-eslint/prefer-promise-reject-errors": "off",
      "react/jsx-sort-props": "off",
    },
  },
  {
    ignores: [".prettierrc.js", "docs/**", "target/**"],
  },
]);
