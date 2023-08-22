require 'test_helper'

class Payments::Payment::SendEmailTest < ActiveSupport::TestCase
  test "sends email for payment" do
    user = create :user
    payment = create(:payments_payment, user:)

    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob, args: [
        "DonationsMailer",
        "payment_created",
        "deliver_now",
        { params: { payment: }, args: [] }
      ]
    ) do
      Payments::Payment::SendEmail.(payment)
    end
  end
end
