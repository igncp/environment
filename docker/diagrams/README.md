This is a docker image intended to group many services that can produce diagrams from code.

## Installation

You must manually download the following files:

- Java JDK:
    - https://www.oracle.com/technetwork/java/javase/downloads/index.html
    - Place it under `files/java-jdk.tar.gz`
- PlantUML Jar file:
    - http://plantuml.com/download
    - Place it under `files/plantuml.jar`
- Entr:
    - http://eradman.com/entrproject/
    - Place it under `files/entr.tar.gz`

## Usage

```sh
sh build.sh
sh run.sh

# recommended
sh scripts/all_entr.sh
```

## Supported

- Graphviz:
    - https://graphviz.gitlab.io/download/
    - https://graphviz.gitlab.io/_pages/doc/info/attrs.html
- PlantUML:
    - http://plantuml.com
- mermaid:
    - https://mermaidjs.github.io/flowchart.html
    - https://mermaidjs.github.io/demos.html

## Ideas not supported yet

- None

## Examples

- From `.dot` to `.png`
    - `dot -Tpng -o ./results/dot-1.png ./examples/dot-1.dot`
- From `.txt` to `.png` using PlantUML
    - `java -jar files/plantuml.jar examples/plantuml-1.txt -o ../results`
- From `.mmd` (mermaid) to `.png`
    - `mmdc -p puppeteer-config.json -i examples/mermaid-1.mmd -o results/mermaid-1.png`
