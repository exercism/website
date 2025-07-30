module Auth
  class RegistrationsController < Devise::RegistrationsController
    skip_before_action :authenticate_user!
    before_action :configure_permitted_parameters
    before_action :verify_turnstile!, only: [:create]

    def create
      super do |user|
        if user.persisted?
          User::Bootstrap.(
            user,
            course_access_code: session[:course_access_code]
          )
        end
      end
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[name handle])
    end

    def after_inactive_sign_up_path_for(_resource)
      auth_confirmation_required_path
    end

    private
    def verify_turnstile!
      raise "Turnstile: No response token" unless params['cf-turnstile-response'].present?

      # Validate the token using Cloudflare Turnstile API
      url = 'https://challenges.cloudflare.com/turnstile/v0/siteverify'.freeze
      payload = {
        secret: Exercism.secrets.turnstile_secret,
        response: params['cf-turnstile-response']
      }

      response = RestClient.post(url, payload.to_json, { content_type: :json, accept: :json })
      outcome = JSON.parse(response.body)

      # If we've got a success, then we're done here.
      return if outcome['success']

      Rails.logger.error "Turnstile verification not successful"
      Rails.logger.error "Turnstile: #{outcome}"
      raise "Turnstile: verification unsuccessful"
    rescue StandardError => e
      Rails.logger.error "Turnstile error: #{e.class} - #{e.message}"
      Rails.logger.error "Turnstile Response body: #{e.response.body}" if e.respond_to?(:response) && e.response&.body

      flash.now[:alert] = "CAPTCHA verification failed. Please try again."
      self.resource = build_resource(sign_up_params)
      render :new, status: :unprocessable_entity
    end
  end
end
