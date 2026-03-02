// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
const vscode = require('vscode');

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

			const response = await fetch('http://localhost:3000/api/chats/1/message', {
				method: 'POST',
				headers: {
				'Content-Type': 'application/json',
				// Optional auth header:
				// 'Authorization': 'Bearer YOUR_API_KEY'
				},
				body: JSON.stringify({ message: selection })
			});

			if (!response.ok) {
				throw new Error(`HTTP error! status: ${response.status}`);
			}

			const data = await response.json();
			console.log('Response from API:', data);
			vscode.window.showInformationMessage(`AI Response: ${data.response}`);
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
