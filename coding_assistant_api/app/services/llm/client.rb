module Llm
  class Client
    def initialize
      @provider = ProviderRegistry.fetch(ENV["LLM_PROVIDER"])
    end

    def generate(prompt:, temperature: 0.7, max_tokens: 1000)
      @provider.generate(
        prompt: prompt,
        temperature: temperature,
        max_tokens: max_tokens
      )
    end
  end
end