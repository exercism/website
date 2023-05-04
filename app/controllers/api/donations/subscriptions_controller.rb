module API
  module Donations
    class SubscriptionsController < BaseController
      def cancel
        subscription = current_user.donation_subscriptions.find(params[:id])
        ::Donations::Stripe::Subscription::Cancel.(subscription)

        render json: {
          subscription: {
            links: {
              index: donations_settings_url
            }
          }
        }
      end

      def update_amount
        subscription = current_user.donation_subscriptions.find(params[:id])
        ::Donations::Stripe::Subscription::UpdateAmount.(subscription, params[:amount_in_cents])

        render json: {
          subscription: {
            links: {
              index: donations_settings_url
            }
          }
        }
      end
    end
  end
end
