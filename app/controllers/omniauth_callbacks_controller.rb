class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!
  include Devise::Controllers::Rememberable

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])

    remember_me(@user)

    sign_in_and_redirect @user, event: :authentication
  end
end
