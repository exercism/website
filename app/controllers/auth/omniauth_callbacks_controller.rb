module Auth
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :authenticate_user!

    include Devise::Controllers::Rememberable

    def github
      if user_signed_in?
        User::LinkWithGithub.(current_user, request.env["omniauth.auth"])
        return redirect_to integrations_settings_path
      end

      @user = User::AuthenticateFromOmniauth.(request.env["omniauth.auth"])

      if @user.persisted?
        remember_me(@user)
        sign_in_and_redirect @user, event: :authentication
      else
        set_flash_message(:alert, :failure, kind: "GitHub") if is_navigational_format?

        redirect_to after_omniauth_failure_path_for(resource_name)
      end
    end

    def discord
      User::LinkWithDiscord.(current_user, request.env["omniauth.auth"])
      redirect_to integrations_settings_path
    end

    def failure
      set_flash_message(:alert, :failure, kind: OmniAuth::Utils.camelize(failed_strategy.name))

      redirect_to after_omniauth_failure_path_for(resource_name)
    end
  end
end
