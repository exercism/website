require 'test_helper'

class User::Mailshot::SendTest < ActiveSupport::TestCase
  test "upcoming_jose_valim: sends email" do
    user = create :user

    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob, args: [
        "MailshotsMailer",
        "upcoming_jose_valim",
        "deliver_now",
        { params: {
          user:,
          email_communication_preferences_key: :email_about_events
        }, args: [] }
      ]
    ) do
      assert User::Mailshot::Send.(user, :upcoming_jose_valim)
    end
  end

  test "upcoming_jose_valim: email not sent if email_about_events is false" do
    user = create :user
    user.communication_preferences.update(email_about_events: false)

    assert_no_enqueued_jobs do
      refute User::Mailshot::Send.(user, :upcoming_jose_valim)
    end
  end
end
