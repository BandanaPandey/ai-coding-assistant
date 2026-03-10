#This scans your entire repo and stores embeddings.
module Rag
  class RepoIndexer

    CODE_EXTENSIONS = %w[
      .rb .js .ts .py .go .java .cpp .rs
    ]

    CHUNK_SIZE = 500
    #Rag::RepoIndexer.new(Rails.root).index
    def initialize(repo_path)
      @repo_path = repo_path
    end

    def index
      files.each do |file|
        content = File.read(file)
        chunks(content).each do |chunk|
          embedding = Rag::Embedder.embed(chunk)
          CodeEmbedding.create!(
            file_path: file,
            content: chunk,
            embedding: embedding
          )
        end
      end
    end

    private

    def files
      Dir.glob("#{@repo_path}/**/*")
         .select { |f| CODE_EXTENSIONS.include?(File.extname(f)) }
    end

    def chunks(text)
      text.scan(/.{1,#{CHUNK_SIZE}}/m)
    end
  end
end