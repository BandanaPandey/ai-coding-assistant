module Llm
  class ContextRouter
    LARGE_PROMPT_THRESHOLD = 8000
    LARGE_CODE_THRESHOLD = 2000
    MULTI_FILE_THRESHOLD = 2

    FAST_TASKS = %w[
      explain
      autocomplete
      quick_fix
    ]

    SMART_TASKS = %w[
      refactor
      generate_tests
      architecture
      debugging
    ]

    def route(task_type:, prompt:, rag_results: [], selected_code:)
      return :smart if smart_task?(task_type)
      return :smart if large_prompt?(prompt)
      return :smart if large_code?(selected_code)
      return :smart if multi_file_context?(rag_results)
      return :fast if FAST_TASKS.include?(task_type)
      :fast
    end

    private

    def smart_task?(task_type)
      SMART_TASKS.include?(task_type)
    end

    def large_prompt?(prompt)
      prompt.length > LARGE_PROMPT_THRESHOLD
    end

    def large_code?(selected_code)
      selected_code.length > LARGE_CODE_THRESHOLD
    end

    def multi_file_context?(rag_results)
      rag_results.size >= MULTI_FILE_THRESHOLD
    end
  end
end