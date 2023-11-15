# This is the base controller of Exercism's API.
#
# It is intended to be consumed by authenticated
# user of Exercism, and is developed in parallel with
# Exercism's Command Line Interface (CLI)

module API
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_after_action :set_body_class_header
    skip_around_action :mark_notifications_as_read!
    skip_after_action :updated_last_visited_on!

    rescue_from ActionController::RoutingError, with: -> { render_404 }

    layout false

    def authenticate_user
      return if user_signed_in?

      authenticate_with_http_token do |token|
        return if token.blank?

        user = User::AuthToken.find_by!(token:).user
        sign_in(user)
      end
    rescue ActiveRecord::RecordNotFound
      # User isn't found and so isn't signed in.
    end

    def authenticate_user!
      authenticate_user

      render_401 unless user_signed_in?
    end

    def ensure_onboarded!
      return unless user_signed_in?
      return if current_user.onboarded?

      render_403(:not_onboarded)
    end

    def ensure_automator!
      return if current_user&.staff?
      return if current_user&.track_mentorships&.automator&.exists?

      render_403(:not_automator)
    end

    def ensure_maintainer!
      return if current_user&.maintainer?
      return if current_user&.admin? # Admins have maintainer permissions

      render_403(:not_maintainer)
    end

    def ensure_trainer!
      return if current_user&.trainer?(@track)

      render_403(:not_trainer)
    end

    def sideload?(item)
      return false unless params[:sideload]

      params[:sideload].include?(item.to_s)
    end

    def render_400(type, data = {})
      render_error(400, type, data)
    end

    def render_401
      render_error(401, :invalid_auth_token)
    end

    def render_403(type = :permission_denied)
      render_error(403, type)
    end

    def render_404(type = :resource_not_found, data = {})
      render_error(404, type, data)
    end

    def render_track_not_found
      render_404(:track_not_found)
    end

    def render_exercise_not_found
      render_404(:exercise_not_found)
    end

    def render_solution_not_found
      render_404(:solution_not_found)
    end

    def render_solution_not_accessible
      render_403(:solution_not_accessible)
    end

    def render_iteration_not_found
      render_404(:iteration_not_found)
    end

    def render_submission_not_found
      render_404(:submission_not_found)
    end

    def render_submission_not_accessible
      render_403(:submission_not_accessible)
    end

    def render_file_not_found
      render_404(:file_not_found)
    end

    def render_error(status, type, data = {})
      message = I18n.t("api.errors.#{type}")

      render json: {
        error: {
          type:,
          message:
        }.merge(data)
      }, status:
    end
  end
end
