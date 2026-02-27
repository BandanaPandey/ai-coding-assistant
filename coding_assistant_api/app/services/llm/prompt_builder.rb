module Llm
  class PromptBuilder
    def initialize(context)
      @context = context
    end

    def build
      <<~PROMPT
        You are a coding assistant specialized in:
        - Ruby
        - Rails
        - JavaScript
        - System design

        Rules:
        - Provide clean code
        - Add comments
        - Explain briefly
        - Suggest improvements

        #{@context}

        ASSISTANT:
      PROMPT
    end
  end
end