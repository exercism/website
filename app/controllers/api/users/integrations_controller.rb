module API
  module Users
    class IntegrationsController < BaseController
      def disconnect_discord
        current_user.update!(discord_uid: nil)
      end
    end
  end
end
