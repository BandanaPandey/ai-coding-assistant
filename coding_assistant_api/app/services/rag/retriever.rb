#This finds most relevant code chunks.
module Rag
  class Retriever
    def self.search(query, limit: 5)
      embedding = Rag::Embedder.embed(query)
      results = CodeEmbedding
              .order(
                Arel.sql("embedding <-> '#{embedding}'")
              )
              .limit(limit)
      # results = CodeEmbedding
      #           .nearest_neighbors(:embedding, embedding, distance: "cosine")
      #           .limit(limit)
      #           .pluck(:content)

      results.map do |doc|
        {
          file_path: doc.file_path,
          content: doc.content
        }
      end
    end
  end
end