require 'test_helper'

class User::Notification::SendEmailTest < ActiveSupport::TestCase
  test "sends email" do
    user = create :user
    notification = create(:mentor_started_discussion_notification, :unread, user:)

    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob, args: [
        "NotificationsMailer",
        "mentor_started_discussion",
        "deliver_now",
        { params: { notification: }, args: [] }
      ]
    ) do
      User::Notification::SendEmail.(notification)
    end
  end

  test "sends different type of email" do
    user = create :user
    notification = create(:student_replied_to_discussion_notification, :unread, user:)

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: [
                           "NotificationsMailer",
                           "student_replied_to_discussion",
                           "deliver_now",
                           { params: { notification: }, args: [] }
                         ]) do
      User::Notification::SendEmail.(notification)
    end
  end
end
