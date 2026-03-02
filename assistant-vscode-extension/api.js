async function askAI(message) {
  const response = await fetch('http://localhost:3000/api/chats/1/message', {
				method: 'POST',
				headers: {
				'Content-Type': 'application/json',
				// Optional auth header:
				// 'Authorization': 'Bearer YOUR_API_KEY'
				},
				body: JSON.stringify({ message: message })
	    });

    if (!response.ok) {
		throw new Error(`HTTP error! status: ${response.status}`);
	}

  return await response.json();
}

module.exports = { askAI };

