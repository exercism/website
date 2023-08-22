class Payments::Payment::UpdateAmount
  include Mandate

  initialize_with :provider, :external_id, :amount_in_cents

  def call
    payment = Payments::Payment.find_by(external_id:, provider:)
    return unless payment

    payment.update!(amount_in_cents:)

    User::UpdateTotalDonatedInCents.(payment.user)
    User::InsidersStatus::UpdateForPayment.(payment.user)
  end
end
