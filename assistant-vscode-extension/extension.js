// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
const vscode = require('vscode');
const { askAI, indexRepository, indexFile  } = require("./api");

const SUPPORTED_LANGUAGES = [
  "javascript",
  "typescript",
  "ruby",
  "python",
  "go",
  "java",
  "cpp",
  "rust"
];

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {

  setupAutoIndexing(context);

  const explainCommand = vscode.commands.registerCommand('assistant-vscode-extension.explain', () => {
    handleAiRequest('explain');
  });

  const refactorCommand = vscode.commands.registerCommand('assistant-vscode-extension.refactor', () => {
    handleAiRequest('refactor');
  });

  const generateTestsCommand = vscode.commands.registerCommand('assistant-vscode-extension.generateTests', () => {
    handleAiRequest('generate_tests');
  });

  /*
  NEW COMMAND
  */
  const indexRepoCommand = vscode.commands.registerCommand(
    'assistant-vscode-extension.indexRepository',
    async () => {

      vscode.window.withProgress({
        location: vscode.ProgressLocation.Notification,
        title: "GOAT AI indexing repository (incremental)...",
        cancellable: false
      }, async () => {
        try {
          const response = await indexRepository();
          vscode.window.showInformationMessage(
            response.message || "Incremental repository indexing started"
          );
        } catch (error) {
          vscode.window.showErrorMessage(
            "Indexing failed: " + error.message
          );
        }
      });
    }
  );

  context.subscriptions.push(
    explainCommand,
    refactorCommand,
    generateTestsCommand,
    indexRepoCommand
  );
}

/**
 * Automatically index files when saved
 */
function setupAutoIndexing(context) {
  const disposable = vscode.workspace.onDidSaveTextDocument(async (document) => {
    try {
      if (!SUPPORTED_LANGUAGES.includes(document.languageId)) {
        return;
      }
      const filePath = document.uri.fsPath;
      console.log("GOAT-AI indexing file:", filePath);

      await indexFile(filePath);

    } catch (error) {
      console.error("Auto indexing failed:", error);
    }
  });
  context.subscriptions.push(disposable);
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

    const filePath = document.uri.fsPath;

    const workspaceFolder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath || "";

    const surroundingCode = getSurroundingCode(document, edselection);

    vscode.window.withProgress({
      location: vscode.ProgressLocation.Notification,
      title: `GOAT-AI running task: ${taskType.replace('_', ' ')}...`,
      cancellable: false
    }, async () => {

      //const result = await askAI(selection, taskType);
      const result = await askAI({
        code: selection,
        task_type: taskType,
        file_path: filePath,
        repo_path: workspaceFolder,
        language: language,
        surrounding_code: surroundingCode
      });

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
Extract surrounding code for better RAG retrieval
*/
function getSurroundingCode(document, selection) {

  const startLine = Math.max(selection.start.line - 20, 0);
  const endLine = Math.min(
    selection.end.line + 20,
    document.lineCount
  );

  const range = new vscode.Range(
    startLine,
    0,
    endLine,
    0
  );

  return document.getText(range);
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
