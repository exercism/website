FactoryBot.define do
  factory :payments_payment, class: 'Payments::Payment' do
    user
    external_id { SecureRandom.uuid }
    external_receipt_url { "https://#{SecureRandom.uuid}" }
    amount_in_cents { 1000 }

    trait :stripe do
      provider { :stripe }
    end

    trait :github do
      provider { :github }
    end

    trait :paypal do
      provider { :paypal }
    end
  end
end
