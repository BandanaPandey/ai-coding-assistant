#This finds most relevant code chunks.
module Rag
  class Retriever
    def self.search(query, user_id:, repository_id:,limit: 5)
      embedding = Embeddings::Client.new.embed(query)
      results = CodeEmbedding
              .where(user_id: user_id)
              .where(repository_id: repository_id)
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