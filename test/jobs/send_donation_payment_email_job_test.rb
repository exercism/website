require "test_helper"

class SendDonationEmailJobTest < ActiveJob::TestCase
  test "sends email" do
    payment = create :donations_payment

    Donations::Payment::SendEmail.expects(:call).with(payment)

    SendDonationPaymentEmailJob.perform_now(payment)
  end
end
