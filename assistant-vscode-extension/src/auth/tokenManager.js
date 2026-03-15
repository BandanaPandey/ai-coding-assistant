const TOKEN_KEY = "goatai.jwt";

async function saveToken(context, token) {
  await context.secrets.store(TOKEN_KEY, token);
}

async function getToken(context) {
  return await context.secrets.get(TOKEN_KEY);
}

async function deleteToken(context) {
  await context.secrets.delete(TOKEN_KEY);
}

module.exports = {
  saveToken,
  getToken,
  deleteToken
};