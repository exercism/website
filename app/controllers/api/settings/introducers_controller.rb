module API
  module Settings
    class IntroducersController < BaseController
      def hide
        current_user.dismiss_introducer!(params[:id])

        render json: {}
      end
    end
  end
end
