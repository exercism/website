FactoryBot.define do
  factory :donations_subscription, class: 'Donations::Subscription' do
    user
    provider { :stripe }
    external_id { SecureRandom.uuid }
    amount_in_cents { 1000 }
  end
end
