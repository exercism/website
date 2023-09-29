class API::Settings::AuthTokensController < API::BaseController
  def reset
    current_user.create_auth_token!

    render json: {
      auth_token: current_user.auth_token
    }
  end
end
