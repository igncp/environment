#!/usr/bin/env bash

set -e

composer create-project drupal/recommended-project test_site
cd test_site
cp ~/development/environment/src/project_templates/drupal/{.,}* .

mkdir web/sites/default/files
sudo chown -R $USER:33 web/sites/default/files
sudo chmod g+w web/sites/default/files

cp web/sites/default/default.settings.php web/sites/default/settings.php
sudo chown -R $USER:33 web/sites/default/settings.php
sudo chmod g+w web/sites/default/settings.php

docker compose up -d

# 造訪「http://localhost:8000」進行安裝
# 新增“.env”中的憑證（並將主機從“docker-compose.yml”新增至“mysql”）
# 完成安裝

sudo chmod g-w web/sites/default/settings.php

# 在“settings.php”中新增“trusted_host_patterns”選項
