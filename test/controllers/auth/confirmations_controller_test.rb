require "test_helper"

module Auth
  class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
    test "redirects to login page on CSRF failure" do
      ActionController::Base.allow_forgery_protection = true

      post user_confirmation_path, params: {
        user: { email: "user@exercism.org" }
      }

      assert_redirected_to new_user_session_path
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end
end
