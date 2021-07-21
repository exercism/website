require "test_helper"

class ViewComponentTestCase < ActionView::TestCase
  include Devise::Test::ControllerHelpers

  def sign_in!(user = nil)
    @current_user = user || create(:user)
    @current_user.auth_tokens.create! unless @current_user.auth_tokens.exists?

    @current_user.confirm
    sign_in @current_user
  end
end
