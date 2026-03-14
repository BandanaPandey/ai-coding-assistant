class RepoIndexJob < ApplicationJob
  queue_as :default

  def perform(repo_path)
    Rails.logger.info "Starting repo indexing..."
    Rag::RepoIndexer.new(repo_path).index
    Rails.logger.info "Repo indexing completed."
  end
end