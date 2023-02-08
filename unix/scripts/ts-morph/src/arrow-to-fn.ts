import { SyntaxKind } from "ts-morph";
import { createFile, defaultFileName, format, handleArgs } from "./common";

export const transform = async (
  content: string,
  fileName = defaultFileName
) => {
  const sourceFile = createFile(content, fileName);

  const arrowFunction = sourceFile.getDescendantsOfKind(
    SyntaxKind.ArrowFunction
  )[0];

  if (!arrowFunction) {
    return sourceFile;
  }

  const hasBlock = arrowFunction.getChildrenOfKind(SyntaxKind.Block).length > 0;
  const returnType = arrowFunction.getChildrenOfKind(SyntaxKind.TypeReference);
  const parent = arrowFunction.getParentOrThrow();
  const params = arrowFunction.getParameters();

  let functionText = "function";

  functionText += ` (${params.map((p) => p.getText()).join(", ")})`;

  if (returnType.length > 0) {
    functionText += `: ${returnType[0].getText()}`;
  }

  functionText += " {";

  functionText += hasBlock
    ? arrowFunction.getBodyText()
    : " return " + arrowFunction.getBodyText() + ";";

  functionText += " }";

  parent.replaceWithText(functionText);

  format(sourceFile);

  return sourceFile;
};

handleArgs(transform);
