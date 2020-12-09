FactoryBot.define do
  factory :exercise_contributorship, class: 'Exercise::Contributorship' do
    exercise { create :concept_exercise }
    contributor { create :user }
  end
end
