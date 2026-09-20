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

    test "redirects to registration page on CSRF failure" do
      ActionController::Base.allow_forgery_protection = true

      post user_registration_path, params: {
        user: {
          name: "User",
          handle: "user22",
          email: "user@exercism.org",
          password: "password",
          password_confirmation: "password"
        }
      }

      assert_redirected_to new_user_registration_path
    ensure
      ActionController::Base.allow_forgery_protection = false
    end

    test "seeds the locale from a prefixed signup page" do
      stub_turnstile!

      post "/hu#{user_registration_path}", params: signup_params

      assert_equal "hu", User.find_by(email: "user@exercism.org").data.locale
    end

    test "seeds the locale from accept-language on a naked signup page" do
      stub_turnstile!

      post user_registration_path, params: signup_params, headers: { "Accept-Language" => "hu,en;q=0.5" }

      assert_equal "hu", User.find_by(email: "user@exercism.org").data.locale
    end

    private
    def stub_turnstile!
      RestClient.unstub(:post)
      stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify").
        to_return(body: { success: true }.to_json)
    end

    def signup_params
      {
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
