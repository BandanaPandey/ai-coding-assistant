const vscode = require("vscode");

const { saveToken } = require("./tokenManager");

async function login(context) {

  const apiKey = await vscode.window.showInputBox({
    prompt: "Enter GOAT AI API Key",
    password: true
  });

  if (!apiKey) {
    return;
  }

  const response = await fetch(
    "http://localhost:3000/api/auth/login",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ api_key: apiKey })
    }
  );

  const data = await response.json();

  if (data.token) {
    await saveToken(context, data.token);
    vscode.window.showInformationMessage("GOAT AI login successful");
  } else {
    vscode.window.showErrorMessage("Login failed");
  }
}

module.exports = { login };