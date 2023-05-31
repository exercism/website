class Payments::Payment::UpdateAmount
  include Mandate

  initialize_with :provider, :external_id, :amount_in_cents

  def call
    payment = Payments::Payment.find_by(external_id:, provider:)
    return unless payment

    payment.update!(amount_in_cents:)

    if payment.donation?
      User::UpdateTotalDonatedInCents.(payment.user)
    elsif payment.premium?
      User::Premium::Update.(user)
    end
  end
end
