class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!
  include Devise::Controllers::Rememberable

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      remember_me(@user)
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.github_data"] = request.env["omniauth.auth"].except(:extra)

      set_flash_message(:alert, :failure, kind: "GitHub") if is_navigational_format?

      redirect_to after_omniauth_failure_path_for(resource_name)
    end
  end
end
