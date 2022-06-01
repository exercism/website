class Donations::Payment
  class SendEmail
    include Mandate

    initialize_with :payment

    def call
      User::SendEmail.(payment) do
        DonationsMailer.with(payment:).payment_created.deliver_later
      end
    end
  end
end
