require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "index shows" do
    get "/"
    assert_response 200
  end

  test "index redirects if logged n" do
    sign_in!
    get "/"
    assert_redirected_to "http://www.example.com/dashboard"
  end
end
