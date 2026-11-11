require "test_helper"

class Auth::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  # This runs OmniAuth's real request and callback phases, with only GitHub's
  # HTTP calls stubbed. Test mode skips the OAuth state that the callback uses
  # to find the params posted with the sign-up form.
  test "a GitHub sign-up keeps the answers posted with the sign-up form" do
    track = create :track, slug: "go"

    post user_github_omniauth_authorize_path, params: { seniority: "junior", sign_up_track_slug: "go" }
    assert_response :redirect
    state = Rack::Utils.parse_query(URI.parse(response.location).query)["state"]
    assert state.present?

    stub_github_oauth!

    get user_github_omniauth_callback_path, params: { code: "the-code", state: }

    user = User.find_by!(email: "gh-user@exercism.org")
    assert_equal :junior, user.data.seniority
    assert_equal track, user.data.sign_up_track
  end

  test "a GitHub sign-up from the sign-in page leaves the answers blank" do
    post user_github_omniauth_authorize_path
    state = Rack::Utils.parse_query(URI.parse(response.location).query)["state"]

    stub_github_oauth!

    get user_github_omniauth_callback_path, params: { code: "the-code", state: }

    user = User.find_by!(email: "gh-user@exercism.org")
    assert_nil user.data.seniority
    assert_nil user.data.sign_up_track
  end

  private
  def stub_github_oauth!
    stub_request(:post, "https://github.com/login/oauth/access_token").
      to_return(status: 200, headers: { "Content-Type" => "application/json" },
        body: { access_token: "the-token", token_type: "bearer", scope: "user:email" }.to_json)

    stub_request(:get, "https://api.github.com/user").
      to_return(status: 200, headers: { "Content-Type" => "application/json" },
        body: { id: 12_345, login: "gh-user", name: "GH User", email: "gh-user@exercism.org",
                avatar_url: "https://avatars.githubusercontent.com/u/12345" }.to_json)

    stub_request(:get, %r{\Ahttps://api\.github\.com/user/emails}).
      to_return(status: 200, headers: { "Content-Type" => "application/json" },
        body: [{ email: "gh-user@exercism.org", primary: true, verified: true }].to_json)
  end
end
