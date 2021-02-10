FactoryBot.define do
  factory :started_exercise_user_activity, class: "User::Activities::StartedExerciseActivity" do
    user
    track
    solution { create :concept_solution }

    params do
      {
        solution: create(:concept_solution)
      }
    end
  end

  factory :submitted_iteration_user_activity, class: "User::Activities::SubmittedIterationActivity" do
    user
    track
    solution { create :concept_solution }

    params do
      {
        iteration: create(:iteration)
      }
    end
  end
end
