module Webhooks
  class RepoUpdatesController < BaseController
    def create
      ::Webhooks::ProcessRepoUpdate.(params[:ref], params[:repository][:name])

      head :no_content
    end
  end
end
