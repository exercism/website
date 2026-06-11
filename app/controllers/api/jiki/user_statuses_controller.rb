module API
  module Jiki
    class UserStatusesController < BaseController
      def show
        user = ::User.find_by(id: params[:exercism_id])
        render json: ::User::Jiki::UserStatus.(user)
      end
    end
  end
end
