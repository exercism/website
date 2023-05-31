require 'test_helper'

class Payments::Payment::SendEmailTest < ActiveSupport::TestCase
  test "sends email for donation payment" do
    user = create :user
    payment = create(:payments_payment, :donation, user:)

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

  test "sends email for premium payment" do
    user = create :user
    payment = create(:payments_payment, :premium, user:)

    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob, args: [
        "PremiumMailer",
        "payment_created",
        "deliver_now",
        { params: { payment: }, args: [] }
      ]
    ) do
      Payments::Payment::SendEmail.(payment)
    end
  end
end
