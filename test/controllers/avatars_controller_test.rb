require "test_helper"

class AvatarsControllerTest < ActionDispatch::IntegrationTest
  test "serves avatars with nosniff" do
    user = create :user

    get "/avatars/#{user.id}/#{user.version}"

    assert_response :ok
    assert_equal "nosniff", response.headers["X-Content-Type-Options"]
  end
end
