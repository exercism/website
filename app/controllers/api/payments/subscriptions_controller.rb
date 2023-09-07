class API::Payments::SubscriptionsController < API::BaseController
  def cancel
    subscription = current_user.subscriptions.find(params[:id])
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
    subscription = current_user.subscriptions.find(params[:id])

    ::Payments::Stripe::Subscription::UpdateAmount.(subscription, params[:amount_in_cents])

    render json: {
      subscription: {
        links: {
          index: donations_settings_url
        }
      }
    }
  end

  def current
    render json: AssembleCurrentSubscription.(current_user)
  end
end
