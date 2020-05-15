FactoryBot.define do
  factory :exercise_prerequisite, class: 'Exercise::Prerequisite' do
    exercise { create(:concept_exercise) }
    track_concept
  end
end
