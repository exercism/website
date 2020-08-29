# This is the base controller of Exercism's API.
#
# It is intended to be consumed by authenticated
# user of Exercism, and is developed in parallel with
# Exercism's Command Line Interface (CLI)

module API
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user!

    rescue_from ActionController::RoutingError, with: -> { render_404 }

    layout false

    def authenticate_user!
      authenticate_with_http_token do |token, _options|
        break if token.blank?

        user = User::AuthToken.find_by(token: token).try(:user)
        break unless user

        # TODO: - Switch when Devise is added
        # sign_in(user) and return
        @current_user = user
        return
      end

      render_401
    end

    def render_401
      render_error(401, :invalid_auth_token)
    end

    def render_403(type)
      render_error(403, type)
    end

    def render_404(type = :resource_not_found, data = {})
      render_error(404, type, data)
    end

    def render_solution_not_found
      render_404(:solution_not_found)
    end

    def render_solution_not_accessible
      render_403(:solution_not_accessible)
    end

    def render_file_not_found
      render_404(:file_not_found)
    end

    def render_error(status, type, data = {})
      message = I18n.t("api.errors.#{type}")

      render json: {
        error: {
          type: type,
          message: message
        }.merge(data)
      }, status: status
    end
  end
end
