class RepoIndexJob < ApplicationJob
  queue_as :default

  def perform(user_id:, repository_id:)
    Rails.logger.info "Starting repo indexing for user_id: #{user_id}, repository_id: #{repository_id}"
    user = User.find(user_id)
    repository = Repository.find(repository_id)
    Rag::RepoIndexer.new(
      user: user,
      repository: repository
    ).index
    Rails.logger.info "Repo indexing completed for user_id: #{user_id}, repository_id: #{repository_id}"
  end
end