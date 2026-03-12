require 'httparty'

module Llm
  module Providers
    class OllamaProvider < BaseProvider
      include HTTParty
      base_uri ENV["OLLAMA_URL"]

      def generate(prompt:, model:, temperature:, max_tokens:)
        puts "Sending prompt to Ollama:\n#{prompt}"
        
        response = self.class.post(
          "/api/generate",
          body: {
            model: model,
            prompt: prompt,
            options: {
              temperature: temperature,
              num_predict: max_tokens
            },
            stream: false
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

        JSON.parse(response.body)["response"]
      end
    end
  end
end