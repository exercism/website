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

    test "stores the sign-up answers" do
      stub_turnstile!
      track = create :track, slug: "go"

      params = signup_params
      params[:user][:seniority] = "beginner"
      params[:user][:sign_up_track_slug] = "go"
      post user_registration_path, params: params

      data = User.find_by(email: "user@exercism.org").data
      assert_equal :beginner, data.seniority
      assert_equal track, data.sign_up_track
    end

    test "a failed sign-up keeps the answers for the form" do
      stub_turnstile!

      params = signup_params
      params[:user][:handle] = "not a handle!"
      params[:user][:seniority] = "senior"
      post user_registration_path, params: params

      assert_response :ok
      assert_select "#sign-up-flow[data-initial-step=form]"
      assert_select "input[name='user[seniority]'][value=senior]"
      assert_select "input[name=seniority][value=senior]"
    end

    test "the sign-up page starts on the questions" do
      get new_user_registration_path

      assert_response :ok
      assert_select "#sign-up-flow[data-initial-step=level]"
      assert_select "input[name='user[seniority]'][value='']"
      assert_select "#sign-up-jiki-dialog"
    end

    test "the code check offers the tracks with a sign-up snippet" do
      go = create :track, slug: "go", title: "Go"
      create :track, slug: "ruby", title: "Ruby"
      Track::RetrieveSignUpCodeCheckTracks.stubs(:call).returns([go])

      get new_user_registration_path

      assert_select "[data-language-select] option[value=go]", text: "Go"
      assert_select "[data-language-select] option[value=ruby]", count: 0
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
