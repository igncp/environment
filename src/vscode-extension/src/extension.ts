import { ExtensionContext, commands, window, Position } from "vscode";

export function activate(context: ExtensionContext): void {
  let disposable = commands.registerCommand(
    "igncp-vscode-extension.easyLog",
    async () => {
      const editor = window.activeTextEditor;
      if (!editor) {
        window.showWarningMessage("No editor instance");
        return;
      }

      const { document, selection } = editor;

      if (selection.isEmpty) {
        window.showWarningMessage("No selection");
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
        window.showErrorMessage("Failed to insert debug log");
      }
    },
  );

  context.subscriptions.push(disposable);
}

export function deactivate(): void {}
