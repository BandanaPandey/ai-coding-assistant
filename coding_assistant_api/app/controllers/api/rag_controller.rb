class Api::RagController < Api::BaseController
  def index
    puts("RAG Controller index action called")
    repo_path = params[:repo_path]
    
    unless Dir.exist?(repo_path)
      return render json: { error: "Invalid repo path" }, status: 400
    end

    repository = current_user.repositories.find_or_create_by!(
      repo_path: repo_path
    )

    #RepoIndexJob.perform_later(user_id: current_user.id, repository_id: repository.id)
    RepoIndexJob.perform_now(user_id: current_user.id, repository_id: repository.id)
    render json: {
      status: "indexing started",
      repository_id: repository.id,
      repo_path: repo_path
    }
  end

  def index_file
    repo_path = params[:repo_path]
    file_path = params[:file_path]
    content = params[:content]

    unless repo_path && file_path
      return render json: { error: "Missing repo_path or file_path" }, status: 400
    end

    repository = current_user.repositories.find_by(
      repo_path: repo_path
    )

    unless repository
      return render json: { error: "Repository not registered" }, status: 404
    end

    Rag::RepoIndexer.new(user: current_user,repository: repository)
                    .index_file(file_path, content)

    render json: {
      message: "File indexed successfully",
      repository_id: repository.id,
      file_path: file_path
    }
  end
end