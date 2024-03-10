module.exports = {
  extends: ["stylelint-config-standard-scss"],
  plugins: ["stylelint-scss", "stylelint-order"],
  rules: {
    "alpha-value-notation": null,
    "block-no-empty": true,
    "color-function-notation": null,
    "color-no-invalid-hex": true,
    "comment-no-empty": true,
    "declaration-block-no-duplicate-properties": true,
    "declaration-block-no-redundant-longhand-properties": true,
    "font-family-no-duplicate-names": true,
    "function-calc-no-unspaced-operator": true,
    "function-calc-no-unspaced-operator": true,
    "length-zero-no-unit": true,
    "media-feature-range-notation": null,
    "media-query-no-invalid": null,
    "no-descending-specificity": null,
    "no-duplicate-selectors": true,
    "no-invalid-double-slash-comments": true,
    "selector-anb-no-unmatchable": true,
    "selector-anb-no-unmatchable": true,
    "shorthand-property-no-redundant-values": true,

    "scss/at-import-no-partial-leading-underscore": null,
    "scss/at-import-partial-extension": null,
    "scss/at-mixin-argumentless-call-parentheses": "never",
    "scss/dollar-variable-colon-space-after": null,
    "scss/dollar-variable-empty-line-before": null,
    "scss/function-no-unknown": null,
    "scss/no-duplicate-dollar-variables": true,
    "scss/no-duplicate-mixins": true,
    "scss/selector-no-redundant-nesting-selector": true,

    "selector-class-pattern": null,
    "selector-id-pattern": null,
    "selector-pseudo-class-no-unknown": null, // Error with `:global` in CSS Modules

    "order/properties-alphabetical-order": true,
  },
};