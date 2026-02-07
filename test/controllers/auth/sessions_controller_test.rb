require "test_helper"

module Auth
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    test "redirects to login page on CSRF failure" do
      Auth::SessionsController.any_instance.stubs(:verify_authenticity_token).raises(
        ActionController::InvalidAuthenticityToken
      )

      post user_session_path, params: {
        user: {
          email: "user@exercism.org",
          password: "password"
        }
      }

      assert_redirected_to new_user_session_path
    end
  end
end
