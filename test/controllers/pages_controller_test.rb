require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "index shows" do
    get "/"
    assert_response :ok
  end

  test "index redirects if logged n" do
    sign_in!
    get "/"
    assert_redirected_to "http://test.exercism.org/dashboard"
  end

  # Cloudflare serves these in production, so Rails only ever sees them in dev
  # and test. It must answer rather than raise: the editor asks for a manifest
  # on every page load, and an unhandled routing error fails any system test
  # that opens the editor.
  test "test runner artifacts 404 rather than raising" do
    get "/test-runners/ruby/latest.json"
    assert_response :not_found
  end

  test "health_check works" do
    user = create :user, :system

    get "/health-check"

    assert_response :ok
    expected = {
      ruok: true,
      sanity_data: {
        user: user.handle
      }
    }
    assert_equal expected.to_json, response.body
  end
end
