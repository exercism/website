class ApplicationController < ActionController::Base
  # TODO: Remove when devise is added
  def user_logged_in?
    !!current_user
  end

  def current_user
    User.first
  end

  %w[index show].each do |action|
    define_method action do
      if user_logged_in? && respond_to?("authenticated_#{action}")
        send("authenticated_#{action}")
        render action: "authenticated/#{action}"
      elsif !user_logged_in? && respond_to?("external_#{action}")
        send("external_#{action}")
        render action: "external/#{action}"
      end
    end
  end
end
