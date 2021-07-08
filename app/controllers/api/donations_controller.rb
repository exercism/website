module API
  class DonationsController < BaseController
    def create
      subscription = Donations::Subscription::Create.(current_user, params[:amount_in_dollars])
      render json: {
        client_secret: subscription.client_secret
      }
    end
  end
end
