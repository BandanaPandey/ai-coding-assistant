# app/services/embeddings/providers/huggingface_provider.rb
module Embeddings
  module Providers
    class HuggingfaceProvider < BaseProvider
      def embed(text)
        uri = URI("https://api-inference.huggingface.co/pipeline/feature-extraction/sentence-transformers/all-MiniLM-L6-v2")
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{ENV['HF_API_KEY']}"
        request.body = { inputs: text }.to_json
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.request(request)
        JSON.parse(response.body).first
      end
    end
  end
end