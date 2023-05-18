class Payments::Payment::SendEmail
  include Mandate

  queue_as :notifications

  initialize_with :payment

  def call
    User::SendEmail.(payment) do
      mailer.with(payment:).payment_created.deliver_later
    end
  end

  private
  def mailer = payment.premium? ? PremiumMailer : DonationsMailer
end
