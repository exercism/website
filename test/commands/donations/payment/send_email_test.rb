require 'test_helper'

class Donations::Payment::SendEmailTest < ActiveSupport::TestCase
  test "sends email" do
    user = create :user
    payment = create(:donations_payment, user:)

    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob, args: [
        "DonationsMailer",
        "payment_created",
        "deliver_now",
        { params: { payment: }, args: [] }
      ]
    ) do
      Donations::Payment::SendEmail.(payment)
    end
  end
end
