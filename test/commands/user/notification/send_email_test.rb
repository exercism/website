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

  test "sends different type of email" do
    user = create :user
    notification = create :student_replied_to_discussion_notification, :unread, user: user

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: [
                           "NotificationsMailer",
                           "student_replied_to_discussion",
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

  test "does not send if user's email is github placeholder" do
    user = create :user, email: "foo@users.noreply.github.com"
    notification = create(:notification, :unread, user: user)

    assert_no_enqueued_jobs do
      User::Notification::SendEmail.(notification)
    end

    assert notification.email_skipped?
  end

  test "does not send if preference set to false" do
    user = create :user
    user.communication_preferences.update(email_on_mentor_started_discussion_notification: false)
    notification = create(:notification, :unread, user: user)

    assert_no_enqueued_jobs do
      User::Notification::SendEmail.(notification)
    end

    assert notification.email_skipped?

    # Reset things
    notification.email_pending!
    notification.unread!
    user.communication_preferences.update(email_on_mentor_started_discussion_notification: true)
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      User::Notification::SendEmail.(notification)
    end
  end

  test "only sends if unread or email only" do
    notification = create(:notification, :pending)
    assert_no_enqueued_jobs do
      User::Notification::SendEmail.(notification)
    end
    assert notification.email_skipped?

    notification = create(:notification, :read)
    assert_no_enqueued_jobs do
      User::Notification::SendEmail.(notification)
    end
    assert notification.email_skipped?

    notification = create(:notification, :unread)
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      User::Notification::SendEmail.(notification)
    end
    assert notification.email_sent?

    notification = create(:notification, :email_only)
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      User::Notification::SendEmail.(notification)
    end
    assert notification.email_sent?
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
