FactoryBot.define do
  factory :exercise_taught_concept, class: 'Exercise::TaughtConcept' do
    exercise { create :concept_exercise }
    concept { create :concept }
  end
end
