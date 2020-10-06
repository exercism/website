class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # TODO: Remove when devise is added
  def authenticate_user!
    raise "Not logged in" unless user_logged_in?
  end

  def current_user
    @__current_user__ ||= User.first # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def user_logged_in?
    !!current_user
  end

  def self.allow_unauthenticated!(*actions)
    skip_before_action(:authenticate_user!, only: actions)

    actions.each do |action|
      define_method action do
        if user_logged_in?
          send("authenticated_#{action}")
          render action: "#{action}/authenticated" unless performed?
        elsif !user_logged_in?
          send("external_#{action}")
          render action: "#{action}/external" unless performed?
        end
      end
    end
  end
end
