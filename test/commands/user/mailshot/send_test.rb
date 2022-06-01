require 'test_helper'

class User::Mailshot::SendTest < ActiveSupport::TestCase
  test "sends v3_launch email" do
    user = create :user

    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob, args: [
        "MailshotsMailer",
        "v3_launch",
        "deliver_now",
        { params: { user: }, args: [] }
      ]
    ) do
      User::Mailshot::Send.(user, :v3_launch)
    end
  end
end
