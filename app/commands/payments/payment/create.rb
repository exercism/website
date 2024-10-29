# This responds to a new payment that has been made
# and creates a record of it in our database. The actual
# creation of the payment within Stripe happens through
# "payment intents".

class Payments::Payment::Create
  include Mandate

  initialize_with :user, :provider, :external_id, :amount_in_cents, :external_receipt_url, subscription: nil

  def call
    Payments::Payment.create!(
      user:,
      provider:,
      external_id:,
      external_receipt_url:,
      subscription:,
      amount_in_cents:
    ).tap do |payment|
      User::UpdateTotalDonatedInCents.(user)
      User::RegisterAsDonor.(user, Time.current)
      User::InsidersStatus::UpdateForPayment.(user)
      Payments::Payment::SendEmail.defer(payment)
    end
  rescue ActiveRecord::RecordNotUnique
    Payments::Payment.find_by!(external_id:, provider:)
  end
end
