FactoryBot.define do
  factory :exercise_approach_tag, class: 'Exercise::Approach::Tag' do
    approach { create :exercise_approach }
    tag { "construct:if" }

    trait :random do
      tag { "construct:#{SecureRandom.hex}" }
    end
  end
end
