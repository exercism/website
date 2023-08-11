FactoryBot.define do
  factory :payments_subscription, class: 'Payments::Subscription' do
    user
    provider { :stripe }
    external_id { SecureRandom.uuid }
    amount_in_cents { 1000 }

    trait :canceled do
      status { :canceled }
    end

    trait :overdue do
      status { :overdue }
    end

    trait :active do
      status { :active }
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
