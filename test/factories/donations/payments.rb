FactoryBot.define do
  factory :donations_payment, class: 'Donations::Payment' do
    user
    stripe_id { SecureRandom.uuid }
    stripe_receipt_url { "https://#{SecureRandom.uuid}" }
    amount_in_cents { 1000 }
  end
end
