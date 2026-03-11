# app/services/embeddings/client.rb
module Embeddings
  class Client

    def initialize(provider: ENV["EMBEDDING_PROVIDER"] || "ollama")
      @provider = build_provider(provider)
    end

    def embed(text)
      @provider.embed(text)
    end

    private

    def build_provider(provider)
      case provider
      when "ollama"
        Providers::OllamaProvider.new
      when "openai"
        Providers::OpenaiProvider.new
      when "huggingface"
        Providers::HuggingfaceProvider.new
      when "jina"
        Providers::JinaProvider.new
      else
        raise "Unknown embedding provider: #{provider}"
      end

    end

  end
end