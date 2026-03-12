module Llm
  class Client
    def initialize
      @provider = ProviderRegistry.fetch(ENV["LLM_PROVIDER"])
      @router = ContextRouter.new
    end

    def generate(
      prompt:,
      task_type:,
      selected_code: "",
      rag_results: [],
      temperature: nil,
      max_tokens: 1000
    )

      route = @router.route(
        task_type: task_type,
        prompt: prompt,
        selected_code: selected_code,
        rag_results: rag_results
      )
      puts "Routing to #{route} model for task #{task_type}"
      model = ModelRegistry.model_for(route)
      puts "Selected model: #{model}"
      temperature ||= default_temperature(task_type)
      @provider.generate(
        prompt: prompt,
        model: model,
        temperature: temperature,
        max_tokens: max_tokens
      )

    end

    private

    def default_temperature(task_type)
      case task_type
      when "explain"
        0.3
      when "refactor"
        0.2
      when "generate_tests"
        0.4
      else
        0.5
      end
    end
  end
end