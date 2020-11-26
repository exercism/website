require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "creates auth token after registration" do
    post user_registration_path, params: {
      user: {
        name: "User",
        handle: "user22",
        email: "user@exercism.io",
        password: "password",
        password_confirmation: "password"
      }
    }

    assert_equal 1, User::AuthToken.count
  end
end
