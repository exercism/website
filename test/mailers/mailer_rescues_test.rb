require "test_helper"

class MailerRescuesTest < ActionMailer::TestCase
  test "rescues Mail::Field::IncompleteParseError" do
    user = create :user
    user.update_column(:email, "An@invalid@email")
    notification = create(:joined_exercism_notification, user:)

    NotificationsMailer.with(notification:).joined_exercism.deliver_now
  end

  test "rescues Net::SMTPSyntaxError" do
    user = create :user
    notification = create(:joined_exercism_notification, user:)

    # Stub deliver to raise the SMTP error that Sentry reported
    Mail::Message.any_instance.stubs(:deliver).raises(
      Net::SMTPSyntaxError.new("501 Invalid RCPT TO address provided")
    )

    NotificationsMailer.with(notification:).joined_exercism.deliver_now
  end
end
