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

    test "an account with an oauth password hash is sent back to log in with oauth" do
      create :user, email: "user@exercism.org", encrypted_password: "invalid", provider: "github", confirmed_at: Time.current

      post user_session_path, params: { user: { email: "user@exercism.org", password: "otherpassword" } }

      assert_redirected_to new_user_session_path
      assert_equal "Your account does not have a password. Please use OAuth.", flash[:alert]
    end
  end
end
