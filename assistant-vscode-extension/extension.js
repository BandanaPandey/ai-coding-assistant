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

	// Use the console to output diagnostic information (console.log) and errors (console.error)
	// This line of code will only be executed once when your extension is activated
	console.log('Congratulations, your extension "assistant-vscode-extension" is now active!');

	// The command has been defined in the package.json file
	// Now provide the implementation of the command with  registerCommand
	// The commandId parameter must match the command field in package.json
	const disposable = vscode.commands.registerCommand('assistant-vscode-extension.codingAssistant', async function () {
		// The code you place here will be executed every time your command is executed

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
			console.log('Selected code:', selection);
			const taskType = await vscode.window.showQuickPick(
				['explain', 'refactor', 'generate_tests'],
				{ placeHolder: 'Select AI action' }
			);

			if (!taskType) return;
			 vscode.window.withProgress({
				location: vscode.ProgressLocation.Notification,
				title: "AI is thinking...",
				cancellable: false
				}, async () => {

				const result = await askAI(selection, taskType);

				//vscode.window.showInformationMessage(result.response);
				// Show result in panel instead of popup
				const panel = vscode.window.createWebviewPanel(
					'aiResponse',
					`AI - ${taskType}`,
					vscode.ViewColumn.Beside,
					{}
				);

				panel.webview.html = `
					<html>
					<body>
						<pre>${result.response}</pre>
					</body>
					</html>
				`;
				});
		} catch (error) {
			console.error('An error occurred:', error);
			vscode.window.showErrorMessage('An error occurred: ' + error.message);
			return;
		}
		// Display a message box to the user
		vscode.window.showInformationMessage('AI Coding Assistant executed successfully!');
	});

	context.subscriptions.push(disposable);
}

// This method is called when your extension is deactivated
function deactivate() {}

module.exports = {
	activate,
	deactivate
}
