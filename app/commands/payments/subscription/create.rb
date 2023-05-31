# This responds to a new subscription that has been made
# and creates a record of it in our database. The actual
# creation of the subscription within Stripe happens through
# "payment intents".
class Payments::Subscription::Create
  include Mandate

  initialize_with :user, :provider, :product, :interval, :external_id, :amount_in_cents

  def call
    Payments::Subscription.create!(
      user:,
      provider:,
      product:,
      interval:,
      external_id:,
      amount_in_cents:,
      status: :active
    ).tap do
      case product
      when :donation
        User::UpdateActiveDonationSubscription.(user)
      when :premium
        User::Premium::Update.(user)
      end
    end
  rescue ActiveRecord::RecordNotUnique
    Payments::Subscription.find_by!(external_id:, provider:)
  end
end
