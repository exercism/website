FactoryBot.define do
  factory :exercise_prerequisite do
    exercise { create(:concept_exercise) }
    track_concept
  end
end
