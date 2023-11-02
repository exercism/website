FactoryBot.define do
  factory :exercise_approach_tag, class: 'Exercise::Approach::Tag' do
    approach { create :exercise_approach }
    tag { "construct:if" }
    condition_type { :all }

    trait :random do
      tag { "construct:#{SecureRandom.hex}" }
    end

    trait :all do
      condition_type { :all }
    end

    trait :any do
      condition_type { :any }
    end

    trait :not do
      condition_type { :not }
    end
  end
end
