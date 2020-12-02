class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :ensure_onboarded!

  def ensure_onboarded!
    return unless user_signed_in?
    return if current_user.onboarded?

    redirect_to user_onboarding_path
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
end
