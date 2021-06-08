require 'test_helper'

class User::Notification::RetrieveTest < ActiveSupport::TestCase
  test "sends email" do
    user = create :user
    notification = create :mentor_started_discussion_notification, :unread, user: user

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: [
                           "NotificationsMailer",
                           "mentor_started_discussion",
                           "deliver_now",
                           { params: { notification: notification }, args: [] }
                         ]) do
      User::Notification::SendEmail.(notification)
    end
  end

  test "updates email status" do
    notification = create :notification, :unread
    refute notification.email_sent?
    User::Notification::SendEmail.(notification)
    assert notification.email_sent?
  end

  test "does not sent if preference set to false" do
    user = create :user
    user.communication_preferences.update(email_on_mentor_started_discussion_notification: false)

    assert_no_enqueued_jobs do
      User::Notification::SendEmail.(create(:notification, :read))
    end

    user.communication_preferences.update(email_on_mentor_started_discussion_notification: true)
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      User::Notification::SendEmail.(create(:notification, :unread))
    end
  end

  test "only sends if unread" do
    assert_no_enqueued_jobs do
      User::Notification::SendEmail.(create(:notification, :pending))
    end

    assert_no_enqueued_jobs do
      User::Notification::SendEmail.(create(:notification, :read))
    end

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      User::Notification::SendEmail.(create(:notification, :unread))
    end
  end

  test "only sends for email pending" do
    assert_no_enqueued_jobs do
      User::Notification::SendEmail.(create(:notification, :unread, email_status: :skipped))
    end

    assert_no_enqueued_jobs do
      User::Notification::SendEmail.(create(:notification, :unread, email_status: :sent))
    end

    assert_no_enqueued_jobs do
      User::Notification::SendEmail.(create(:notification, :unread, email_status: :failed))
    end

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      User::Notification::SendEmail.(create(:notification, :unread, email_status: :pending))
    end
  end
end
