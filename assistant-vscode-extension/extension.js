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

    const selection = editor.document.getText(editor.selection);

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
        await handleRefactorReplace(editor, result.response);
      } else {
        showResultInPanel(taskType,result.response);
      }
    });

  } catch (error) {
    console.error(error);
    vscode.window.showErrorMessage(`AI Error: ${error.message}`);
  }
}

async function handleRefactorReplace(editor, refactoredCode) {

  const action = await vscode.window.showInformationMessage(
    "GOAT-AI generated refactored code.",
    "Replace Selection",
    "Preview",
    "Cancel"
  );

  if (action === "Preview") {
    showResultInPanel("Refactored Code", refactoredCode);
    return;
  }

  if (action === "Replace Selection") {

    await editor.edit(editBuilder => {
      editBuilder.replace(editor.selection, refactoredCode);
    });

    vscode.window.showInformationMessage("Code replaced with GOAT-AI refactored version.");
  }
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
// function showResultInPanel(taskType, content) {
//   const panel = vscode.window.createWebviewPanel(
//     'aiResponse',
//     `AI - ${taskType.replace('_', ' ')}`,
//     vscode.ViewColumn.Beside,
//     { enableScripts: false }
//   );

//   panel.webview.html = `
//     <html>
//       <body>
//         <pre style="white-space: pre-wrap;">${content}</pre>
//       </body>
//     </html>
//   `;
// }

// This method is called when your extension is deactivated
function deactivate() {}

module.exports = {
	activate,
	deactivate
}
