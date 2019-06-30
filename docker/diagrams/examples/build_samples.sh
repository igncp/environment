#!/usr/bin/env bash

set -e

cd /home/ubuntu

dot -Tpng -o ./results/dot-1.png ./examples/dot-1.dot
echo "./results/dot-1.png created"

java -jar files/plantuml.jar examples/plantuml-1.txt -o ../results
echo "./results/plantuml-1.png created"

mmdc -p puppeteer-config.json -i examples/mermaid-1.mmd -o results/mermaid-1.png
echo "./results/mermaid-1.png created"
