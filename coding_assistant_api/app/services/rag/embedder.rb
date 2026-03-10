require "net/http"
require "json"
#Generates embeddings using Ollama.
module Rag
  class Embedder

    def self.embed(text)

      uri = URI("http://localhost:11434/api/embeddings")

      response = Net::HTTP.post(
        uri,
        {
          model: "nomic-embed-text",
          prompt: text
        }.to_json,
        "Content-Type" => "application/json"
      )

      JSON.parse(response.body)["embedding"]
    end

  end
end