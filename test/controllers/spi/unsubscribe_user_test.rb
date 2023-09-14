require "test_helper"

class SPI::UnsubscribeUserTest < ActionDispatch::IntegrationTest
  test "unsubscribes correctly" do
    user = create :user

    client = mock
    Exercism.expects(:ses_client).returns(client)
    client.expects(:put_suppressed_destination).with({
      email_address: user.email,
      reason: "BOUNCE"
    })

    User::UnsubscribeFromAllEmails.expects(:call).with(user)

    patch spi_unsubscribe_user_path(
      email: user.email,
      reason: :bounce
    )
  end
end
