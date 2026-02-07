require "test_helper"

module Auth
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    test "redirects to login page on CSRF failure" do
      ActionController::Base.allow_forgery_protection = true

      post user_session_path, params: {
        user: {
          email: "user@exercism.org",
          password: "password"
        }
      }

      assert_redirected_to new_user_session_path
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end
end
