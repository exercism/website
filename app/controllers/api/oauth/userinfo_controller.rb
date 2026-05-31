module API
  module Oauth
    class UserinfoController < BaseController
      skip_before_action :authenticate_user!, raise: false
      skip_before_action :ensure_onboarded!, raise: false
      skip_before_action :rate_limit_for_user!, raise: false
      before_action :doorkeeper_authorize!

      def show
        render json: User::OauthUserinfo.(current_resource_owner)
      end

      private
      def current_resource_owner
        @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id)
      end
    end
  end
end
