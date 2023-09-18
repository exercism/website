class Payments::Payment::SendEmail
  include Mandate

  queue_as :notifications

  initialize_with :payment

  def call
    User::SendEmail.(payment) do
      DonationsMailer.with(payment:).payment_created.deliver_later
    end
  end
end
