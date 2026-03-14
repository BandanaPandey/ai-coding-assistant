class Api::RagController < ApplicationController
  def index
    #RepoIndexJob.perform_later
    RepoIndexJob.perform_now
    render json: { status: "indexing started" }
  end

  def index_file
    file_path = params[:file_path]

    unless File.exist?(file_path)
      return render json: { error: "File not found" }, status: 404
    end

    Rag::RepoIndexer.new(Rails.root).index_file(file_path)

    render json: {
      message: "File indexed successfully"
    }
  end
end