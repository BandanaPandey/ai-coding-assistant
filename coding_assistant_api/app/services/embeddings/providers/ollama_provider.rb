# app/services/embeddings/providers/ollama_provider.rb
require "net/http"
require "json"

module Embeddings
  module Providers
    class OllamaProvider < BaseProvider
      OLLAMA_URL = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
      
      def embed(text)
        uri = URI("#{OLLAMA_URL}/api/embeddings")
        puts "OLLAMA_EMBED_MODEL: #{ENV.fetch("OLLAMA_EMBED_MODEL")}"
        body = {
          model: ENV.fetch("OLLAMA_EMBED_MODEL", "nomic-embed-text"),
          prompt: text
        }

        response = Net::HTTP.post(
          uri,
          body.to_json,
          { "Content-Type" => "application/json" }
        )
        json = JSON.parse(response.body)
        json["embedding"]
      end
    end
  end
end