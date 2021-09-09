class SendDonationPaymentEmailJob < ApplicationJob
  queue_as :notifications

  def perform(payment)
    Donations::Payment::SendEmail.(payment)
  end
end
