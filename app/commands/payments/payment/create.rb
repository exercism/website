# This responds to a new payment that has been made
# and creates a record of it in our database. The actual
# creation of the payment within Stripe happens through
# "payment intents".

class Payments::Payment::Create
  include Mandate

  initialize_with :user, :provider, :product, :external_id, :amount_in_cents, :external_receipt_url, subscription: nil

  def call
    Payments::Payment.create!(
      user:,
      provider:,
      product:,
      external_id:,
      external_receipt_url:,
      subscription:,
      amount_in_cents:
    ).tap do |payment|
      if product == :premium
        User::Premium::Update.(user)
      elsif product == :donation
        User::UpdateTotalDonatedInCents.(user)
        User::RegisterAsDonor.(user, Time.current)

        if amount_in_cents >= Premium::LIFETIME_AMOUNT_IN_CENTS
          # Immediately activate a user that donates 499 or more, as it's
          # likely that the reason they're doing it is to immediately
          # get a Premium subscription.
          User::InsidersStatus::Activate.(user, force_lifetime: true)
        else
          User::InsidersStatus::Update.(user)
        end
      end

      Payments::Payment::SendEmail.defer(payment)
    end
  rescue ActiveRecord::RecordNotUnique
    Payments::Payment.find_by!(external_id:, provider:)
  end
end
