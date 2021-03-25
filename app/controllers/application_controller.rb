class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :ensure_onboarded!

  def ensure_onboarded!
    return unless user_signed_in?
    return if current_user.onboarded?

    redirect_to user_onboarding_path
  end

  def ensure_mentor!
    return if current_user&.mentor?

    redirect_to mentoring_path
  end

  def ensure_not_mentor!
    return unless current_user&.mentor?

    redirect_to mentoring_inbox_path
  end

  def self.allow_unauthenticated!(*actions)
    skip_before_action(:authenticate_user!, only: actions)

    actions.each do |action|
      define_method action do
        if user_signed_in?
          send("authenticated_#{action}")
          render action: "#{action}/authenticated" unless performed?
        elsif !user_signed_in?
          send("external_#{action}")
          render action: "#{action}/external" unless performed?
        end
      end
    end
  end

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
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
