require "test_helper"

class SPI::BaseControllerTest < ActionDispatch::IntegrationTest
  test "serves requests on the canonical spi path" do
    user = create :user

    client = mock
    Exercism.expects(:ses_client).returns(client)
    client.expects(:put_suppressed_destination)
    User::UnsubscribeFromAllEmails.expects(:call).with(user)

    patch "/spi/unsubscribe_user", params: { email: user.email, reason: :bounce }

    assert_response :no_content
  end

  test "returns 404 for non-canonical paths" do
    user = create :user
    User::UnsubscribeFromAllEmails.expects(:call).never

    patch "/spi/unsubscribe_user",
      params: { email: user.email, reason: :bounce },
      env: { "PATH_INFO" => "//spi/unsubscribe_user" }

    assert_response :not_found
  end
end
