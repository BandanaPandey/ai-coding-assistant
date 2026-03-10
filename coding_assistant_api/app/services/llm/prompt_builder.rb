# app/services/llm/prompt_builder.rb
module Llm
  class PromptBuilder

    def initialize(context, task_type)
      @context = context
      @task_type = task_type
    end

    def build
      [
        base_instructions,
        task_instructions,
        repo_context_section,
        code_section,
        history_section
      ].join("\n")
    end

    private

    def base_instructions
      <<~PROMPT
        You are a senior software engineer specialized in:
        - Ruby
        - Ruby on Rails
        - JavaScript
        - System Design

        Follow project conventions when possible.
      PROMPT
    end

    def task_instructions
      case @task_type
      when "explain"
        <<~PROMPT
          TASK: Explain the code clearly.
          
          Instructions:
          - Describe what the code does
          - Explain how it interacts with other files
          - Identify bugs or risks
          - Suggest improvements
        PROMPT
      when "refactor"
        <<~PROMPT
          TASK: Refactor the code while keeping functionality unchanged.
          Return improved code first.

          Instructions:
          - Improve readability
          - Reduce complexity
          - Follow best practices
          - Maintain functionality
          - Follow repository style
        PROMPT
      when "generate_tests"
        <<~PROMPT
          TASK: Generate comprehensive tests.
          Use RSpec for Ruby or Jest for JS.

          Instructions:
          - Use RSpec for Ruby
          - Use Jest for JavaScript
          - Include edge cases
          - Mock dependencies if necessary
          - Ensure tests are runnable
        PROMPT
      else
        ""
      end
    end

    def repo_context_section

      return "" if @context[:rag_context].blank?

      context_text = @context[:rag_context].map do |doc|
        <<~DOC
        FILE: #{doc[:file_path]}
        #{doc[:content]}
        DOC
      end.join("\n\n")

      <<~PROMPT
        RELATED CODE FROM REPOSITORY:

        #{context_text}
      PROMPT

    end

    def code_section
      <<~PROMPT
        CURRENT FILE:
        #{@context[:file_path]}

        SELECTED CODE:
        #{@context[:code]}

        SURROUNDING CODE:
        #{@context[:surrounding_code]}
      PROMPT
    end

    def history_section
      <<~PROMPT
        CHAT HISTORY:
        #{@context[:history]}

        ASSISTANT:
      PROMPT
    end

  end
end