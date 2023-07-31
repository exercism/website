FactoryBot.define do
  factory :exercise_approach_introduction_authorship, class: 'Exercise::Approach::Introduction::Authorship' do
    exercise { create :concept_exercise }
    author { create :user }
  end
end
