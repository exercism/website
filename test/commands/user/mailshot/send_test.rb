require 'test_helper'

class User::Mailshot::SendTest < ActiveSupport::TestCase
  test "community_launch: sends email" do
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

  test "community_launch: email not sent if receive_product_updates is false" do
    user = create :user
    user.communication_preferences.update(receive_product_updates: false)

    assert_no_enqueued_jobs do
      User::Mailshot::Send.(user, :community_launch)
    end
  end

  test "company_support_donor: sends email" do
    user = create :user

    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob, args: [
        "MailshotsMailer",
        "company_support_donor",
        "deliver_now",
        { params: { user: }, args: [] }
      ]
    ) do
      User::Mailshot::Send.(user, :company_support_donor)
    end
  end
end
