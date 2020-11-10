FactoryBot.define do
  factory :started_exercise_user_activity, class: "User::Activities::StartedExerciseActivity" do
    user
    track

    params do
      {
        exercise: create(:concept_exercise)
      }
    end
  end

  factory :submitted_iteration_user_activity, class: "User::Activities::SubmittedIterationActivity" do
    user
    track

    params do
      {
        exercise: create(:concept_exercise),
        iteration: create(:iteration)
      }
    end
  end
end
