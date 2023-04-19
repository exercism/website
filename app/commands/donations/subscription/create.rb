# This responds to a new subscription that has been made
# and creates a record of it in our database. The actual
# creation of the subscription within Stripe happens through
# "payment intents".
class Donations::Subscription::Create
  include Mandate

  initialize_with :user, :provider, :external_id, :amount_in_cents

  def call
    Donations::Subscription.create!(
      user:,
      provider:,
      external_id:,
      amount_in_cents:,
      status: :active
    ).tap do
      User::UpdateActiveDonationSubscription.(user)
    end
  rescue ActiveRecord::RecordNotUnique
    Donations::Subscription.find_by!(external_id:, provider:)
  end
end
