class ApplicationController < ActionController::Base
  extend Mandate::Memoize
  include Turbo::Redirection
  include Turbo::CustomFrameRequest

  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :ensure_onboarded!
  before_action :mark_notifications_as_read!

  def process_action(*args)
    super
  rescue ActionDispatch::Http::MimeNegotiation::InvalidType,
         ActionDispatch::Http::Parameters::ParseError => e
    request.headers['Content-Type'] = 'application/json'
    render status: :bad_request, json: { errors: [e.message] }
  end

  def ensure_onboarded!
    return unless user_signed_in?
    return if current_user.onboarded?

    redirect_to user_onboarding_path
  end

  def ensure_admin!
    return if current_user&.admin?

    redirect_to maintaining_root_path
  end

  def mark_notifications_as_read!
    return if devise_controller?
    return unless user_signed_in?
    return unless request.get?
    return unless is_navigational_format?
    return if request.xhr?

    User::Notification::MarkRelevantAsRead.(current_user, request.path)

    User::Notification::MarkBatchAsRead.(current_user, [params[:notification_uuid]]) if params[:notification_uuid].present?
  end

  def ensure_mentor!
    return if current_user&.mentor?

    redirect_to mentoring_path
  end

  def ensure_not_mentor!
    return unless current_user&.mentor?

    redirect_to mentoring_inbox_path
  end

  def country_code = request.location&.country_code.presence

  #############################
  # Site Header Functionality #
  #############################
  def render_site_header?
    iv = "@__render_site_header__"
    instance_variable_defined?(iv) ? instance_variable_get(iv) : true
  end
  helper_method :render_site_header?

  def disable_site_header!
    @__render_site_header__ = false
  end

  def self.disable_site_header!(*args)
    before_action :disable_site_header!, *args
  end

  private
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? &&
      request.fullpath != '/site.webmanifest'
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  memoize
  def namespace_name
    controller_parts = self.class.name.underscore.split("/")
    controller_parts.size > 1 ? controller_parts[0] : nil
  end
  helper_method :namespace_name

  def render_template_as_json
    respond_to do |format|
      format.json do
        render json: {
          html: render_to_string(
            template: [namespace_name, controller_name, action_name].compact.join('/'),
            layout: false,
            formats: [:html]
          )
        }
      end
      format.html do
      end
    end
  end

  def render_404
    render(
      template: 'errors/not_found',
      layout: true,
      status: :not_found
    )
  end
end
