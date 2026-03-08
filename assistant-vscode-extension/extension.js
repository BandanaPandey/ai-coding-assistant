// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
const vscode = require('vscode');
const { askAI } = require("./api");

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {

  const explainCommand = vscode.commands.registerCommand('assistant-vscode-extension.explain', () => {
    handleAiRequest('explain');
  });

  const refactorCommand = vscode.commands.registerCommand('assistant-vscode-extension.refactor', () => {
    handleAiRequest('refactor');
  });

  const generateTestsCommand = vscode.commands.registerCommand('assistant-vscode-extension.generateTests', () => {
    handleAiRequest('generate_tests');
  });

  context.subscriptions.push(
    explainCommand,
    refactorCommand,
    generateTestsCommand
  );
}

/**
 * Common handler for all AI actions
 */
async function handleAiRequest(taskType) {
  try {
    const editor = vscode.window.activeTextEditor;

    if (!editor) {
      vscode.window.showWarningMessage('No active editor found.');
      return;
    }

    const document = editor.document;
    const language = document.languageId;

    const edselection = editor.selection;

    const selection = document.getText(edselection);

    if (!selection || selection.trim() === '') {
      vscode.window.showWarningMessage('Please select some code first.');
      return;
    }

    vscode.window.withProgress({
      location: vscode.ProgressLocation.Notification,
      title: `GOAT-AI is performing following action: ${taskType.replace('_', ' ')}...`,
      cancellable: false
    }, async () => {

      const result = await askAI(selection, taskType);

      if (taskType === "refactor") {
        const cleanedRefactored = cleanCode(result.response);
        /*
        Store document + range BEFORE opening diff
        */
        const documentUri = document.uri;
        const range = new vscode.Range(
          edselection.start,
          edselection.end
        );
        //await showDiff(selection, cleanedRefactored);
        await showDiff(selection, cleanedRefactored, language);

        const action = await vscode.window.showInformationMessage(
          "Apply GOAT-AI refactor?",
          "Apply",
          "Cancel"
        );

        if (action === "Apply") {
          //await replaceCode(editor, cleanedRefactored);
          //vscode.window.showInformationMessage("Code refactored successfully.");
          await applyRefactor(
            documentUri,
            range,
            cleanedRefactored
          );

          vscode.window.showInformationMessage(
            "Refactored code applied successfully"
          );
        }
        //await handleRefactorReplace(editor, result.response);
      } else {
        showResultInPanel(taskType,result.response);
      }
    });

  } catch (error) {
    console.error(error);
    vscode.window.showErrorMessage(`AI Error: ${error.message}`);
  }
}

/*
Show diff preview
*/
async function showDiff(original, refactored, language) {

  const originalDoc = await vscode.workspace.openTextDocument({
    content: original,
    language: language
  });

  const refactoredDoc = await vscode.workspace.openTextDocument({
    content: refactored,
    language: language
  });

  await vscode.commands.executeCommand(
    'vscode.diff',
    originalDoc.uri,
    refactoredDoc.uri,
    'AI Refactor Preview'
  );
}

/*
Apply refactored code safely
*/
async function applyRefactor(documentUri, range, newCode) {

  const workspaceEdit = new vscode.WorkspaceEdit();

  workspaceEdit.replace(documentUri, range, newCode);

  await vscode.workspace.applyEdit(workspaceEdit);

  const document = await vscode.workspace.openTextDocument(documentUri);

  await vscode.window.showTextDocument(document);
}


/*
Remove markdown code fences returned by LLM
*/
function cleanCode(text) {

  if (!text) return "";

  return text
    .replace(/```[\w]*\n/g, '')
    .replace(/```/g, '')
    .trim();
}

/**
 * Render response in side panel
 */
function showResultInPanel(title, content) {

  const panel = vscode.window.createWebviewPanel(
    'aiResult',
    title,
    vscode.ViewColumn.Beside,
    {}
  );

  panel.webview.html = `
    <html>
      <body>
        <pre style="font-size:14px;line-height:1.4;">${content}</pre>
      </body>
    </html>
  `;
}

// This method is called when your extension is deactivated
function deactivate() {}

module.exports = {
	activate,
	deactivate
}
