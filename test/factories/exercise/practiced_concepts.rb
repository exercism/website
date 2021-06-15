FactoryBot.define do
  factory :exercise_practiced_concept, class: 'Exercise::PracticedConcept' do
    exercise { create :practice_exercise }
    concept { create :concept }
  end
end
