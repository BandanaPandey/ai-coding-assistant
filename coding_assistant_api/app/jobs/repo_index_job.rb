class RepoIndexJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting repo indexing..."
    Rag::RepoIndexer.new(Rails.root).index
    Rails.logger.info "Repo indexing completed."
  end
end