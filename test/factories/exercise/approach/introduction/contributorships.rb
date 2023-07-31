FactoryBot.define do
  factory :exercise_approach_introduction_contributorship, class: 'Exercise::Approach::Introduction::Contributorship' do
    exercise { create :concept_exercise }
    contributor { create :user }
  end
end
