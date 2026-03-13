class Api::RagController < ApplicationController
  def index
    RepoIndexJob.perform_later
    #RepoIndexJob.perform_now
    render json: { status: "indexing started" }
  end
end