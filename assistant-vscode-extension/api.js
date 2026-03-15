const BASE_URL = "http://localhost:3000";
const { getToken } = require("./src/auth/tokenManager");

async function askAI(context, payload) {
  const token = await getToken(context);
  if (!token) {
    throw new Error("Not authenticated. Run GOAT AI: Login");
  }
  console.log("Token retrieved in askAI:", token);
  const response = await fetch(`${BASE_URL}/api/chats/1/message`, {
				method: 'POST',
				headers: {
				  "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
				},
				body: JSON.stringify(payload)
	    });

    if (!response.ok) {
		throw new Error(`HTTP error! status: ${response.status}`);
	}

  return await response.json();
}

async function indexRepository(repo_path) {
  const response = await fetch(`${BASE_URL}/api/rag/index`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      repo_path: repo_path
    })
  });

  return await response.json();
}

async function indexFile(repo_path, filePath) {

  const response = await fetch(`${BASE_URL}/api/rag/index_file`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      repo_path: repo_path,
      file_path: filePath
    })
  });

  return await response.json();
}


module.exports = { askAI, indexRepository, indexFile };
