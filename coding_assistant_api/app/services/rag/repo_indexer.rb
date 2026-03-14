require "digest"

module Rag
  class RepoIndexer

    CODE_EXTENSIONS = %w[
      .rb .js .ts .py .go .java .cpp .rs
    ]

    def initialize(repo_path)
      @repo_path = repo_path
    end

    def index
      files.each do |file|
        index_file(file)
      end
    end

    def index_file(file)
      return unless CODE_EXTENSIONS.include?(File.extname(file))

      content = File.read(file)

      file_hash = Digest::SHA256.hexdigest(content)

      existing = CodeEmbedding.where(file_path: file).first

      return if existing && existing.file_hash == file_hash

      CodeEmbedding.where(file_path: file).delete_all

      semantic_chunks = Rag::SemanticChunker
                          .new(content)
                          .chunks

      semantic_chunks.each do |chunk|

        embedding = Embeddings::Client
                     .new
                     .embed(chunk[:content])

        CodeEmbedding.create!(
          repo_path: @repo_path,
          file_path: file,
          content: chunk[:content],
          embedding: embedding,
          file_hash: file_hash,
          start_line: chunk[:start_line]
        )

      end
    end

    private

    def files
      Dir.glob("#{@repo_path}/**/*")
         .select { |f| CODE_EXTENSIONS.include?(File.extname(f)) }
    end
  end
end