const vscode = require("vscode");
const { deleteToken } = require("./tokenManager");

async function logout(context) {

  await deleteToken(context);

  vscode.window.showInformationMessage("GOAT AI logged out");
}

module.exports = { logout };