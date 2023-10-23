import { SyntaxKind, ts } from "ts-morph";
import { createFile, defaultFileName, format, handleArgs } from "./common";

const { factory } = ts;

export const transform = async (
  content: string,
  fileName = defaultFileName
) => {
  const sourceFile = createFile(content, fileName);
  const toBeReplaced = "PropsWithChildren";

  const typeLiterals = sourceFile.getDescendantsOfKind(SyntaxKind.TypeLiteral);
  const interfaces = sourceFile.getDescendantsOfKind(
    SyntaxKind.InterfaceDeclaration
  );

  typeLiterals.forEach((typeLiteral) => {
    const allProperties = typeLiteral.getProperties();

    const childrenProperty = allProperties.find(
      (property) => property.getName() === "children"
    );

    if (childrenProperty) {
      childrenProperty.remove();

      typeLiteral.transform((traversal) => {
        traversal.visitChildren();

        const typedNode = traversal.currentNode as ts.TypeLiteralNode;

        return factory.createIntersectionTypeNode([
          factory.createTypeLiteralNode(typedNode.members),
          factory.createTypeReferenceNode(
            factory.createIdentifier(toBeReplaced),
            undefined
          ),
        ]);
      });
    }
  });

  interfaces.forEach((interfaceDeclaration) => {
    const allProperties = interfaceDeclaration.getProperties();

    const childrenProperty = allProperties.find(
      (property) => property.getName() === "children"
    );

    if (childrenProperty) {
      childrenProperty.remove();

      interfaceDeclaration.transform((traversal) => {
        const typedNode = traversal.currentNode as ts.InterfaceDeclaration;

        return factory.createInterfaceDeclaration(
          undefined,
          factory.createIdentifier(typedNode.name.getText()),
          undefined,
          [
            factory.createHeritageClause(ts.SyntaxKind.ExtendsKeyword, [
              factory.createExpressionWithTypeArguments(
                factory.createIdentifier(toBeReplaced),
                undefined
              ),
            ]),
          ],
          typedNode.members
        );
      });
    }
  });

  try {
    format(sourceFile);
  } catch {}

  return sourceFile;
};

handleArgs(transform);
