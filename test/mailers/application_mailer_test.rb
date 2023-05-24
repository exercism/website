require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "don't send email to user when email_status is invalid" do
    user = create :user, email_status: :invalid
    notification = create(:joined_exercism_notification, user:)

    NotificationsMailer.with(notification:).joined_exercism.deliver_now

    assert_no_emails
  end

  %i[unverified verified].each do |email_status|
    test "send email to user when email_status is #{email_status}" do
      user = create(:user, email_status:)
      notification = create(:joined_exercism_notification, user:)

      NotificationsMailer.with(notification:).joined_exercism.deliver_now

      assert_emails 1
    end
  end
end
