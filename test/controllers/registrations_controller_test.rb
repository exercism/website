require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "creates auth token after registration" do
    RestClient.unstub(:post)
    stub_request(:post, "https://hcaptcha.com/siteverify").
      to_return(body: { success: true }.to_json)

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

    RestClient.stubs(:post)
  end
end
