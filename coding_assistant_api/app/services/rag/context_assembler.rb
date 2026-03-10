# app/services/rag/context_assembler.rb
# Context Assembler (Cursor-Style Context)
# Cursor merges:
# Selected code
# Related files
# Symbols
# Dependencies
# We simulate that here.
module Rag
  class ContextAssembler
    def initialize(code:, task_type:)
      @code = code
      @task_type = task_type
    end

    def build_context
      related = Retriever.search(search_query)
      related_context = format_related_context(related)
      format_context(@code, related_context)
    end

    private

    def search_query
      case @task_type
      when "explain"
        "explain this code #{@code}"
      when "refactor"
        "refactor similar implementation #{@code}"
      when "generate_tests"
        "test examples for #{@code}"
      else
        @code
      end
    end

    def format_related_context(related)
      related.map do |r|
        <<~FILE
        FILE: #{r.file_path}

        #{r.content}

        ---
        FILE
      end.join("\n")
    end

    def format_context(selected_code, related_context)
      <<~CONTEXT
      SELECTED_CODE:
      #{selected_code}

      RELATED_REPO_CONTEXT:
      #{related_context}
      CONTEXT
    end
  end
end