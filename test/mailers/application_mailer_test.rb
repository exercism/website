require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "does not send if user may not receive emails" do
    user = create :user
    user.expects(may_receive_emails?: false)
    notification = create(:joined_exercism_notification, user:)

    NotificationsMailer.with(notification:).joined_exercism.deliver_now

    assert_no_emails
  end

  test "sends email to user when they may receive them" do
    user = create :user
    user.expects(may_receive_emails?: true)
    notification = create(:joined_exercism_notification, user:)

    NotificationsMailer.with(notification:).joined_exercism.deliver_now

    assert_emails 1
  end
end
