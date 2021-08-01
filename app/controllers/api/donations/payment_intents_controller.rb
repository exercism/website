module API
  module Donations
    class PaymentIntentsController < BaseController
      def create
        payment_intent = ::Donations::PaymentIntent::Create.(
          current_user,
          params[:type],
          params[:amount_in_dollars]
        )

        render json: {
          payment_intent: {
            id: payment_intent.id,
            client_secret: payment_intent.client_secret
          }
        }
      end

      def succeeded
        ::Donations::PaymentIntent::HandleSuccess.(id: params[:id])

        render json: {}
      end

      def failed
        ::Donations::PaymentIntent::Cancel.(params[:id])

        render json: {}
      end
    end
  end
end
