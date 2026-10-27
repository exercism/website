require "test_helper"

class SPI::BaseControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! URI(Exercism.config.spi_url).host
  end

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

  test "is not routed on the website host" do
    user = create :user
    User::UnsubscribeFromAllEmails.expects(:call).never
    host! URI(Rails.application.routes.default_url_options[:host]).host

    assert_raises ActionController::RoutingError do
      patch "/spi/unsubscribe_user", params: { email: user.email, reason: :bounce }
    end
  end
end
