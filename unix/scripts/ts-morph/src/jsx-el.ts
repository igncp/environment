import { SyntaxKind, ts } from "ts-morph";
import {
  createFile,
  defaultFileName,
  format,
  getRestParams,
  handleArgs,
} from "./common";

export const transformBase =
  (fromTag: string, toTag: string) =>
  async (content: string, fileName = defaultFileName) => {
    const sourceFile = createFile(content, fileName);

    const jsxElements = sourceFile.getDescendantsOfKind(SyntaxKind.JsxElement);
    const jsxSelfClosingElements = sourceFile.getDescendantsOfKind(
      SyntaxKind.JsxSelfClosingElement
    );

    jsxElements.forEach((jsx) => {
      const tagName = jsx.getOpeningElement().getTagNameNode().getText();

      if (tagName !== fromTag) {
        return;
      }

      const openingElement = jsx.getOpeningElement();
      const closingElement = jsx.getClosingElement();

      openingElement.transform((traversal) => {
        traversal.visitChildren();

        const node = traversal.currentNode as ts.JsxOpeningElement;

        return ts.factory.createJsxOpeningElement(
          ts.factory.createIdentifier(toTag),
          node.typeArguments,
          node.attributes
        );
      });

      closingElement.transform(() => {
        return ts.factory.createJsxClosingElement(
          ts.factory.createIdentifier(toTag)
        );
      });
    });

    jsxSelfClosingElements.forEach((jsx) => {
      const tagName = jsx.getTagNameNode().getText();

      if (tagName !== fromTag) {
        return;
      }

      jsx.transform((traversal) => {
        traversal.visitChildren();

        const node = traversal.currentNode as ts.JsxOpeningElement;

        return ts.factory.createJsxSelfClosingElement(
          ts.factory.createIdentifier(toTag),
          node.typeArguments,
          node.attributes
        );
      });
    });

    try {
      format(sourceFile);
    } catch {}

    return sourceFile;
  };

const restParams = getRestParams();

if (restParams.length === 2) {
  const transform = transformBase(...(restParams as [string, string]));

  handleArgs(transform);
}
