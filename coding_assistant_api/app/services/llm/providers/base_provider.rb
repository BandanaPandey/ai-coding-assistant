module Llm
  module Providers
    class BaseProvider
      def generate(prompt:, model:, temperature:, max_tokens:)
        raise NotImplementedError
      end

      def embed(text:)
        raise NotImplementedError
      end
    end
  end
end