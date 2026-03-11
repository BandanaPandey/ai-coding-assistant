# app/services/embeddings/base_provider.rb
module Embeddings
  class BaseProvider
    def embed(text)
      raise NotImplementedError
    end
  end
end