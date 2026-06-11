module API
  module Jiki
    class UserStatusesController < BaseController
      def create
        ids = Array(params[:exercism_ids])
        statuses = User::JikiStatuses.(ids)
        render json: { statuses: }
      end
    end
  end
end
