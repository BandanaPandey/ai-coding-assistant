module Llm
  module Providers
    class BaseProvider
      def generate(prompt:, temperature: 0.7, max_tokens: 1000)
        raise NotImplementedError
      end

      def embed(text:)
        raise NotImplementedError
      end
    end
  end
end