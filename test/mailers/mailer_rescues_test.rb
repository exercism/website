require "test_helper"

class MailerRescuesTest < ActionMailer::TestCase
  test "rescues Mail::Field::IncompleteParseError" do
    user = create :user
    user.update_column(:email, "An@invalid@email")
    notification = create(:joined_exercism_notification, user:)

    NotificationsMailer.with(notification:).joined_exercism.deliver_now
  end
end
