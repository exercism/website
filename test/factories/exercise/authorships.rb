FactoryBot.define do
  factory :exercise_authorship, class: 'Exercise::Authorship' do
    exercise { create :concept_exercise }
    author { create :user }
  end
end
