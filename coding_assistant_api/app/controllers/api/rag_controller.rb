class Api::RagController < ApplicationController
  def index
    puts("RAG Controller index action called")
    repo_path = params[:repo_path]
    
    unless Dir.exist?(repo_path)
      return render json: { error: "Invalid repo path" }, status: 400
    end

    #RepoIndexJob.perform_later(repo_path)
    RepoIndexJob.perform_now(repo_path)
    render json: { status: "indexing started", repo_path: repo_path}
  end

  def index_file
    repo_path = params[:repo_path]
    file_path = params[:file_path]
    content = params[:content]

    unless repo_path && file_path
      return render json: { error: "Missing repo_path or file_path" }, status: 400
    end

    Rag::RepoIndexer.new(repo_path).index_file(file_path)

    render json: {
      message: "File indexed successfully"
    }
  end
end