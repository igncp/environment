import fs from "fs";
import prettier from "prettier";
import { Project, ProjectOptions, ScriptTarget, SourceFile } from "ts-morph";
import { SemicolonPreference } from "typescript";

type Transform = (content: string, fileName?: string) => Promise<SourceFile>;

export const defaultFileName = "/tmp/ts-morph-default.tsx";

export const getRestParams = () => {
  if (process.env.NODE_ENV === "test") {
    return [];
  }

  return process.argv.slice(3);
};

export const handleArgs = (transform: Transform) => {
  if (process.env.NODE_ENV === "test") {
    return;
  }

  const params = process.argv.slice(2);
  const [fileName] = params;

  if (fileName) {
    const fileContent = fs.readFileSync(fileName, "utf8");

    transform(fileContent, fileName).then((sourceFile) => {
      sourceFile.saveSync();
    });
  }
};

export const createFile = (
  content: string,
  fileName: string,
  opts: ProjectOptions = {}
) => {
  const project = new Project({
    ...opts,
    compilerOptions: {
      target: ScriptTarget.ES3,
      ...opts.compilerOptions,
    },
  });

  return project.createSourceFile(fileName, content, {
    overwrite: true,
  });
};

export const format = (sourceFile: SourceFile) => {
  sourceFile.formatText({
    ensureNewLineAtEndOfFile: false,
    semicolons: SemicolonPreference.Remove,
  });
};

export const expectWithPrettier = (actual: SourceFile, expected: string) => {
  const actualText = prettier.format(actual.getFullText(), {
    parser: "typescript",
  });
  const expectedText = prettier.format(expected, { parser: "typescript" });

  expect(actualText).toEqual(expectedText);
};
