module API
  module Jiki
    class UserStatusesController < BaseController
      def show
        user = ::User.find_by(id: params[:exercism_id])
        render json: ::User::Jiki::DetermineUserStatus.(user)
      end
    end
  end
end
