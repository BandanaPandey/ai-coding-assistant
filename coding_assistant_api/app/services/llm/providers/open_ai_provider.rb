require 'httparty'

module Llm
  module Providers
    class OpenAIProvider < BaseProvider
      include HTTParty
      base_uri "https://api.openai.com"

      def generate(prompt:, model:, temperature:, max_tokens:)
        response = self.class.post(
          "/v1/chat/completions",
          headers: {
            "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}",
            "Content-Type" => "application/json"
          },
          body: {
            model: model,
            messages: [
              { role: "user", content: prompt }
            ],
            temperature: temperature,
            max_tokens: max_tokens
          }.to_json
        )
        JSON.parse(response.body)["choices"][0]["message"]["content"]
      end
    end
  end
end