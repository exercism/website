module Webhooks
  class PushUpdatesController < BaseController
    def create
      ::Webhooks::ProcessPushUpdate.(params[:ref], params[:repository][:name])

      head :no_content
    end
  end
end
