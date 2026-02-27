module Llm
  class ProviderRegistry
    def self.fetch(provider_name)
      case provider_name
      when "ollama"
        Providers::OllamaProvider.new
      when "openai"
        Providers::OpenAIProvider.new
      when "anthropic"
        Providers::AnthropicProvider.new
      else
        raise "Unknown LLM provider"
      end
    end
  end
end