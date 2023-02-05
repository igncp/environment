import { Project, ScriptTarget, SyntaxKind } from "ts-morph";
import fs from "fs";
import { SemicolonPreference } from "typescript";

export const transform = async (content: string) => {
  const project = new Project({
    compilerOptions: {
      target: ScriptTarget.ES3,
    },
  });

  const sourceFile = project.createSourceFile("/tmp/myNewFile.ts", content, {
    overwrite: true,
  });

  const arrowFunction = sourceFile.getDescendantsOfKind(
    SyntaxKind.ArrowFunction
  )[0];

  if (!arrowFunction) {
    return sourceFile;
  }

  const hasBlock = arrowFunction.getChildrenOfKind(SyntaxKind.Block).length > 0;
  const parent = arrowFunction.getParentOrThrow();

  if (!hasBlock) {
    parent.replaceWithText(
      "function () { return " + arrowFunction.getBodyText() + "; }"
    );
  } else {
    parent.replaceWithText(
      "function () { " + arrowFunction.getBodyText() + " }"
    );
  }

  sourceFile.formatText({
    ensureNewLineAtEndOfFile: false,
    semicolons: SemicolonPreference.Remove,
  });

  return sourceFile;
};

const params = process.argv.slice(2);

if (params.length) {
  const fileContent = fs.readFileSync("/tmp/myNewFile.ts", "utf8");

  transform(fileContent).then((sourceFile) => {
    sourceFile.saveSync();
  });
}
