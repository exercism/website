module Webhooks
  class RepoUpdatesController < BaseController
    def create
      ::Webhooks::ProcessRepoUpdate.(params[:ref], params[:repo][:name])

      render json: {}, status: :ok
    end
  end
end
