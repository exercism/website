module API
  module Donations
    class SubscriptionsController < BaseController
      def cancel
        subscription = current_user.donation_subscriptions.find(params[:id])
        ::Donations::Subscription::Cancel.(subscription)

        render json: {
          subscription: {
            links: {
              index: Exercism::Routes.donations_settings_url
            }
          }
        }
      end

      def update_amount
        subscription = current_user.donation_subscriptions.find(params[:id])
        ::Donations::Subscription::UpdateAmount.(subscription, params[:amount_in_dollars])

        render json: {}
      end
    end
  end
end
