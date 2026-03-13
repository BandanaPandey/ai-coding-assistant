const BASE_URL = "http://localhost:3000";

async function askAI(payload) {
  const response = await fetch(`${BASE_URL}/api/chats/1/message`, {
				method: 'POST',
				headers: {
				'Content-Type': 'application/json',
				// Optional auth header:
				// 'Authorization': 'Bearer YOUR_API_KEY'
				},
				body: JSON.stringify(payload)
	    });

    if (!response.ok) {
		throw new Error(`HTTP error! status: ${response.status}`);
	}

  return await response.json();
}

async function indexRepository() {
  const response = await fetch(`${BASE_URL}/api/rag/index`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    }
  });

  return await response.json();
}

module.exports = { askAI, indexRepository };

