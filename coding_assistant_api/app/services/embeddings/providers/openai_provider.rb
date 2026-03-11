# app/services/embeddings/providers/openai_provider.rb
require "net/http"
require "json"
module Embeddings
  module Providers
    class OpenaiProvider < BaseProvider
      def embed(text)
        uri = URI("https://api.openai.com/v1/embeddings")
        body = {
          input: text,
          model: ENV.fetch("OPENAI_EMBED_MODEL", "text-embedding-3-small")
        }
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{ENV['OPENAI_API_KEY']}"
        request["Content-Type"] = "application/json"
        request.body = body.to_json

        response = http.request(request)
        json = JSON.parse(response.body)
        json["data"][0]["embedding"]
      end
    end
  end
end