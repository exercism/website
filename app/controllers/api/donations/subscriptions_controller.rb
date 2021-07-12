module API
  module Donations
    class SubscriptionsController < BaseController
      def create
        subscription = ::Donations::Subscription::Create.(
          current_user,
          params[:amount_in_dollars],
          payment_intent_id: params[:payment_intent_id]
        )
        render json: {
          payment_intent: {
            id: subscription.payment_intent_id,
            client_secret: subscription.payment_intent_client_secret
          }
        }
      end
    end
  end
end
