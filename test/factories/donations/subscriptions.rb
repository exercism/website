FactoryBot.define do
  factory :donations_subscription, class: 'Donations::Subscription' do
    user
    provider { :stripe }
    external_id { SecureRandom.uuid }
    amount_in_cents { 1000 }

    trait :canceled do
      status { :canceled }
    end

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
