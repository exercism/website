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
end
