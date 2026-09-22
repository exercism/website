require "test_helper"

class JikiLinksTest < ActionDispatch::IntegrationTest
  test "a signed-in user's links to jiki use their own locale, even on a naked url" do
    user = create :user
    user.update!(locale: "hu")
    sign_in!(user)

    get "/tracks"

    assert_response :ok
    assert_includes response.body, %(href="https://jiki.io/hu")
    refute_match(%r{href="https://jiki\.io"}, response.body)
  end

  test "english users' links to jiki are unprefixed" do
    sign_in!

    get "/tracks"

    assert_response :ok
    assert_match(%r{href="https://jiki\.io"}, response.body)
  end
end
