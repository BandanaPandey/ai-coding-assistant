module Llm
  module Providers
    class AnthropicProvider < BaseProvider
      include HTTParty
      base_uri "https://api.anthropic.com"

      def generate(prompt:, temperature: 0.7, max_tokens: 1000)
        response = self.class.post(
          "/v1/messages",
          headers: {
            "x-api-key" => ENV["ANTHROPIC_API_KEY"],
            "anthropic-version" => "2023-06-01",
            "Content-Type" => "application/json"
          },
          body: {
            model: ENV["LLM_MODEL"],
            max_tokens: max_tokens,
            temperature: temperature,
            messages: [
              { role: "user", content: prompt }
            ]
          }.to_json
        )

        JSON.parse(response.body)["content"][0]["text"]
      end
    end
  end
end