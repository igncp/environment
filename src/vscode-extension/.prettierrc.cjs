const fs = require('fs');

const config = JSON.parse(
  fs.readFileSync(__dirname + '/node_modules/@igncp/common-config/.prettierrc', 'utf8'),
);

module.exports = config;
