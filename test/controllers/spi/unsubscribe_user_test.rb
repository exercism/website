require "test_helper"

class SPI::UnsubscribeUserTest < ActionDispatch::IntegrationTest
  test "unsubscribes correctly" do
    user = create :user

    User::UnsubscribeFromAllEmails.expects(:call).with(user)

    patch spi_unsubscribe_user_path(
      email: user.email
    )
  end
end
