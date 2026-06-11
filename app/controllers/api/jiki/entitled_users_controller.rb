module API
  module Jiki
    class EntitledUsersController < BaseController
      def index
        render json: {
          insider_ids: ::User::Jiki::EntitledIds.insiders,
          bootcamp_member_ids: ::User::Jiki::EntitledIds.bootcamp_members
        }
      end
    end
  end
end
