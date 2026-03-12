module Llm
  class ModelRegistry
    def self.model_for(route)
      case route
      when :fast
        ENV.fetch("FAST_MODEL")
      when :smart
        ENV.fetch("SMART_MODEL")
      else
        ENV.fetch("FAST_MODEL")
      end
    end
  end
end