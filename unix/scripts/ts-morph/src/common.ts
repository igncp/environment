import fs from "fs";
import { Project, ScriptTarget, SourceFile } from "ts-morph";
import { SemicolonPreference } from "typescript";

type Transform = (content: string, fileName?: string) => Promise<SourceFile>;

export const defaultFileName = "/tmp/ts-morph-default.ts";

export const handleArgs = (transform: Transform) => {
  const params = process.argv.slice(2);
  const [fileName] = params;

  if (fileName) {
    const fileContent = fs.readFileSync(fileName, "utf8");

    transform(fileContent, fileName).then((sourceFile) => {
      sourceFile.saveSync();
    });
  }
};

export const createFile = (content: string, fileName: string) => {
  const project = new Project({
    compilerOptions: {
      target: ScriptTarget.ES3,
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
