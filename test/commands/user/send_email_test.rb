require 'test_helper'

class User::SendEmailTest < ActiveSupport::TestCase
  test "sends email" do
    user = create :user
    notification = create(:mentor_started_discussion_notification, :unread, user:)

    assert_email_sent(notification)
  end

  test "updates email status" do
    notification = create :notification, :unread
    refute notification.email_sent?
    User::Notification::SendEmail.(notification) {}
    assert notification.email_sent?
  end

  test "does not send if user may not receive emails" do
    user = create :user
    user.expects(may_receive_emails?: false)
    notification = create(:notification, :unread, user:)

    refute_email_sent(notification)
  end

  test "does not send if preference set to false" do
    user = create :user
    user.communication_preferences.update(email_on_mentor_started_discussion_notification: false)
    notification = create(:notification, :unread, user:)

    refute_email_sent(notification)

    assert notification.email_skipped?

    # Reset things
    notification.email_pending!
    notification.unread!
    user.communication_preferences.update(email_on_mentor_started_discussion_notification: true)
    assert_email_sent(notification)
  end

  test "only sends if unread or email only" do
    notification = create(:notification, :pending)
    refute_email_sent(notification)
    assert notification.email_skipped?

    notification = create(:notification, :read)
    refute_email_sent(notification)
    assert notification.email_skipped?

    notification = create(:notification, :unread)
    assert_email_sent(notification)
    assert notification.email_sent?

    notification = create(:notification, :email_only)
    assert_email_sent(notification)
    assert notification.email_sent?
  end

  test "only sends for email pending" do
    notification = create(:notification, :unread, email_status: :skipped)
    refute_email_sent(notification)

    notification = create(:notification, :unread, email_status: :sent)
    refute_email_sent(notification)

    notification = create(:notification, :unread, email_status: :failed)
    refute_email_sent(notification)

    notification = create(:notification, :unread, email_status: :pending)
    assert_email_sent(notification)
  end

  def assert_email_sent(emailable)
    called = false
    sending_block = proc { called = true }

    sent = User::SendEmail.(emailable, &sending_block)

    assert sent
    assert called
  end

  def refute_email_sent(emailable)
    sending_block = proc { flunk }

    sent = User::SendEmail.(emailable, &sending_block)

    refute sent
  end
end
