class API::Payments::SubscriptionsController < API::BaseController
  def cancel
    subscription = current_user.subscriptions.find(params[:id])
    ::Payments::Stripe::Subscription::Cancel.(subscription)

    render json: {
      subscription: {
        links: {
          index: subscription.donation? ? donations_settings_url : premium_settings_url
        }
      }
    }
  end

  def update_amount
    subscription = current_user.subscriptions.find(params[:id])
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

  def update_plan
    subscription = current_user.subscriptions.find(params[:id])
    return render_403(:no_premium_subscription) unless subscription.premium?

    ::Payments::Stripe::Subscription::UpdatePlan.(subscription, params[:interval].to_sym)

    render json: {
      subscription: {
        links: {
          index: premium_settings_url
        }
      }
    }
  end

  def create_paypal_premium
    subscription = ::Payments::Paypal::Subscription::CreateForPremium.(current_user, params[:interval])

    render json: {
      subscription: {
        links: {
          approve: subscription[:links].find { |link| link[:rel] == 'approve' }[:href]
        }
      }
    }
  end
end
