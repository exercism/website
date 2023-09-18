require 'test_helper'

class User::Mailshot::SendTest < ActiveSupport::TestCase
  test "sends email" do
    user = create :user
    mailshot = create :mailshot

    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob, args: [
        "MailshotsMailer",
        "mailshot",
        "deliver_now",
        { params: {
          user:,
          mailshot:
        }, args: [] }
      ]
    ) do
      assert User::Mailshot::Send.(user, mailshot)
    end
  end

  test "email not sent if email_about_events is false" do
    user = create :user
    mailshot = create :mailshot, email_communication_preferences_key: :email_about_events
    user.communication_preferences.update(email_about_events: false)

    assert_no_enqueued_jobs do
      refute User::Mailshot::Send.(user, mailshot)
    end
  end
end
