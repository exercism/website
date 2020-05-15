require "test_helper"

class ExerciseFlowsTest < ActiveSupport::TestCase
  test "start a track and submit an exercise" do
    track = create :track
    concept_exercise_basics = create :concept_exercise, track: track, slug: 'basics', prerequisites: []
    concept_exercise_strings = create :concept_exercise, track: track, slug: 'strings', prerequisites: []
    create :exercise_prerequisite, exercise: concept_exercise_strings
    user = create :user

    # User joins the track
    # Check its retrieved correctly.
    ut = User::JoinTrack.call(user, track)
    assert_equal ut, UserTrack.for!(user, track)

    # Check we only have basics to start with
    assert_equal [concept_exercise_basics], ut.available_concept_exercises

    # Start the exercise and get a solution
    basics_solution = User::StartExercise.(ut, concept_exercise_basics)

    # Submit an iteration
    Iteration::UploadWithExercise.stubs(:call)
    Iteration::UploadForStorage.stubs(:call)
    basics_iteration_1 = User::SubmitIteration.(basics_solution, [{filename: "basics.rb", content: "my code"}])

    Iteration::TestRun::Process.(basics_iteration_1.uuid, 200, "success", {
      status: :pass,
      message: nil,
      tests: [{
        name: "test1",
        status: "pass"
      }]
    })

    Iteration::Analysis::Process.(basics_iteration_1.uuid, 200, "success", {
      status: :pass,
      comments: [{
        name: "test1",
        data: []
      }]
    })
  end
end
