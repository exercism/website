class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # TODO: Remove when devise is added
  def authenticate_user!
    raise "Not logged in" unless user_signed_in?
  end

  def current_user
    @__current_user__ ||= User.first # rubocop:disable Naming/MemoizedInstanceVariableName
  end
  helper_method :current_user

  def user_signed_in?
    !!current_user
  end
  helper_method :user_signed_in?

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
end
