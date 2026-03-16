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
    def initialize(current_user:, repository:, code:, task_type:)
      @current_user = current_user
      @repository = repository
      @code = code
      @task_type = task_type
    end

    def build_context
      Retriever.search(search_query, user_id: @current_user.id, repository_id: @repository.id)
      # related_context = format_related_context(related)
      # format_context(@code, related_context)
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