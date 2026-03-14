#This finds most relevant code chunks.
module Rag
  class Retriever
    def self.search(query,repo_path,limit: 5)
      embedding = Embeddings::Client.new.embed(query)
      results = CodeEmbedding
              .where(repo_path: repo_path)
              .order(
                Arel.sql("embedding <-> '#{embedding}'")
              )
              .limit(limit)

      results.map do |doc|
        {
          file_path: doc.file_path,
          content: doc.content
        }
      end
    end
  end
end