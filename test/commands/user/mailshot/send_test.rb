require 'test_helper'

class User::Mailshot::SendTest < ActiveSupport::TestCase
  test "sends community_launch email" do
    user = create :user

    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob, args: [
        "MailshotsMailer",
        "community_launch",
        "deliver_now",
        { params: { user: }, args: [] }
      ]
    ) do
      User::Mailshot::Send.(user, :community_launch)
    end
  end

  test "not sent if receive_product_updates is false" do
    user = create :user
    user.communication_preferences.update(receive_product_updates: false)

    assert_no_enqueued_jobs do
      User::Mailshot::Send.(user, :community_launch)
    end
  end
end
