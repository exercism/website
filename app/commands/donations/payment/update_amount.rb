class Donations::Payment::UpdateAmount
  include Mandate

  initialize_with :provider, :external_id, :amount_in_cents

  def call
    payment = Donations::Payment.find_by(external_id:, provider:)
    return unless payment

    payment.update!(amount_in_cents:)
    User::UpdateTotalDonatedInCents.(payment.user)
  end
end
