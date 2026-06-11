module API
  module Jiki
    class EntitledUsersController < BaseController
      def index
        render json: {
          insider_ids: ::User::Jiki::RetrieveInsiderIds.(),
          bootcamp_member_ids: ::User::Jiki::RetrieveBootcampMemberIds.()
        }
      end
    end
  end
end
