module API
  module Donations
    class ActiveSubscriptionsController < BaseController
      def show
        render json: AssembleActiveSubscription.(current_user)
      end
    end
  end
end
