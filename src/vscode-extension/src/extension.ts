import * as path from 'path';
import {
  commands,
  env,
  ExtensionContext,
  Position,
  RelativePattern,
  window,
  workspace,
} from 'vscode';

export function activate(context: ExtensionContext): void {
  context.subscriptions.push(
    commands.registerCommand('igncp-vscode-extension.easyLog', async () => {
      const editor = window.activeTextEditor;

      if (!editor) {
        window.showWarningMessage('冇編輯器實例');

        return;
      }

      const { document, selection } = editor;

      if (selection.isEmpty) {
        window.showWarningMessage('No selection');

        return;
      }

      const text = document.getText(selection).trim();
      const startLine = selection.start.line;
      const line = document.lineAt(startLine);

      const indent = line.text.substring(
        0,
        line.firstNonWhitespaceCharacterIndex,
      );

      const lineBelowPosition = new Position(startLine + 1, 0);

      const wrappedText = `${indent}console.log('debug: ${text}', JSON.stringify(${text}, null, 2));\n`;

      const success = await editor.edit((editBuilder) => {
        editBuilder.insert(lineBelowPosition, wrappedText);
      });

      if (!success) {
        window.showErrorMessage('插入除錯日誌失敗');
      }
    }),
  );

  context.subscriptions.push(
    commands.registerCommand(
      'igncp-vscode-extension.copyFileDirPath',
      async () => {
        const editor = window.activeTextEditor;

        if (!editor) {
          window.showWarningMessage('冇編輯器實例');

          return;
        }

        const { document } = editor;
        const filePath = document.uri.fsPath;
        const dirPath = filePath.substring(0, filePath.lastIndexOf('/'));

        const wsFolder = workspace.getWorkspaceFolder(document.uri);
        const workspaceFsPath = wsFolder?.uri.fsPath;

        const relativeDirPath = workspaceFsPath
          ? path.relative(workspaceFsPath, dirPath)
          : dirPath;

        await env.clipboard.writeText(relativeDirPath);
        window.showInformationMessage(`Copied directory path: ${dirPath}`);
      },
    ),
  );

  context.subscriptions.push(
    commands.registerCommand(
      'igncp-vscode-extension.copyFileRelativePathMonorepo',
      async () => {
        const editor = window.activeTextEditor;

        if (!editor) {
          window.showWarningMessage('冇編輯器實例');

          return;
        }

        const { document } = editor;
        const filePath = document.uri.fsPath;

        const wsFolder = workspace.getWorkspaceFolder(document.uri);
        const workspaceFsPath = wsFolder?.uri.fsPath;

        const relativeFilePath = workspaceFsPath
          ? path.relative(workspaceFsPath, filePath)
          : filePath;

        const parsedFilePath = relativeFilePath.replace(
          /^packages\/[^/]+\//,
          '',
        );

        await env.clipboard.writeText(parsedFilePath);
        window.showInformationMessage(`Copied file path: ${relativeFilePath}`);
      },
    ),
  );

  context.subscriptions.push(
    commands.registerCommand(
      'igncp-vscode-extension.copyGitLogLineRange',
      async () => {
        const editor = window.activeTextEditor;

        if (!editor) {
          window.showWarningMessage('冇編輯器實例');

          return;
        }

        const { document, selection } = editor;
        const filePath = document.uri.fsPath;
        const startLine = selection.start.line + 1;
        const finishLine =
          selection.end.character === 0 &&
          selection.end.line > selection.start.line
            ? selection.end.line
            : selection.end.line + 1;
        const gitLogLineRange = `${startLine},${finishLine}:${filePath}`;

        await env.clipboard.writeText(gitLogLineRange);
        window.showInformationMessage(
          `已複製 Git 日誌範圍：${gitLogLineRange}`,
        );
      },
    ),
  );

  context.subscriptions.push(
    commands.registerCommand(
      'igncp-vscode-extension.listFilesInDirOrBelow',
      async () => {
        const editor = window.activeTextEditor;

        if (!editor) {
          window.showWarningMessage('冇編輯器實例');

          return;
        }

        const filePath = editor.document.uri.fsPath;
        const dirPath = filePath.substring(0, filePath.lastIndexOf('/'));

        const allFilesInDirPath = await workspace.findFiles(
          new RelativePattern(dirPath, '**/*'),
        );

        const items = allFilesInDirPath.map((uri) => ({
          description: path.relative(dirPath, uri.fsPath),
          label: path.basename(uri.fsPath),
          uri,
        }));

        const selectedItem = await window.showQuickPick(items, {
          placeHolder: 'Select a file to open',
        });

        if (selectedItem) {
          const document = await workspace.openTextDocument(selectedItem.uri);

          await window.showTextDocument(document);
        }
      },
    ),
  );
}

export function deactivate(): void {}
