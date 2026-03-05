# app/services/llm/prompt_builder.rb
module Llm
  class PromptBuilder
    def initialize(context, task_type)
      @context = context
      @task_type = task_type
    end

    def build
      base_instructions + task_instructions + context_section
    end

    private

    def base_instructions
      <<~PROMPT
        You are a senior software engineer specialized in:
        - Ruby
        - Ruby on Rails
        - JavaScript
        - System Design

        General Rules:
        - Provide clean, production-ready code
        - Add meaningful comments
        - Follow best practices
        - Keep explanations concise
        - Suggest improvements when appropriate

      PROMPT
    end

    def task_instructions
      case @task_type
      when "explain"
        <<~PROMPT
          TASK: Explain the following code clearly.
          - Describe what it does
          - Identify potential issues
          - Suggest improvements if any

        PROMPT

      when "refactor"
        <<~PROMPT
          TASK: Refactor the following code.
          - Improve readability
          - Improve performance if possible
          - Apply best practices
          - Keep functionality unchanged
          - Return only the improved code and short explanation

        PROMPT

      when "generate_tests"
        <<~PROMPT
          TASK: Generate comprehensive test cases.
          - Use RSpec for Ruby/Rails
          - Use Jest for JavaScript
          - Cover edge cases
          - Include setup and teardown if needed
          - Provide complete runnable test code

        PROMPT

      else
        ""
      end
    end

    def context_section
      <<~PROMPT
        CODE:
        #{@context}

        ASSISTANT:
      PROMPT
    end
  end
end