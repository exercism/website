FactoryBot.define do
  factory :exercise_prerequisite, class: 'Exercise::Prerequisite' do
    exercise { create :concept_exercise }
    concept { create :concept }
  end
end
