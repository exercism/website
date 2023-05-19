class API::Payments::ActiveSubscriptionsController < API::BaseController
  def show
    render json: AssembleActiveSubscription.(current_user)
  end
end
