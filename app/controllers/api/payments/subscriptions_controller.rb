class API::Payments::SubscriptionsController < API::BaseController
  def cancel
    subscription = current_user.payment_subscriptions.find(params[:id])
    ::Payments::Stripe::Subscription::Cancel.(subscription)

    render json: {
      subscription: {
        links: {
          index: donations_settings_url
        }
      }
    }
  end

  def update_amount
    subscription = current_user.payment_subscriptions.find(params[:id])
    return render_403(:no_donation_subscription) unless subscription.donation?

    ::Payments::Stripe::Subscription::UpdateAmount.(subscription, params[:amount_in_cents])

    render json: {
      subscription: {
        links: {
          index: donations_settings_url
        }
      }
    }
  end
end
