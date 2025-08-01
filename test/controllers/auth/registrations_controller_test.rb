require "test_helper"

module Auth
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    test "bootstraps new users" do
      RestClient.unstub(:post)
      stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify").
        to_return(body: { success: true }.to_json)

      User::Bootstrap.expects(:call).with do |user|
        assert user.is_a?(User)
      end

      post user_registration_path, params: {
        user: {
          name: "User",
          handle: "user22",
          email: "user@exercism.org",
          password: "password",
          password_confirmation: "password"
        },
        "cf-turnstile-response": "valid_turnstile_response"
      }
    end
  end
end
