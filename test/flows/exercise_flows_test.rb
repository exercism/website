require 'test_helper'

class ExerciseFlowsTest < ActiveSupport::TestCase
  test 'start a track and submit an exercise that gets approved' do
    track = create :track
    concept_exercise_basics = create :concept_exercise, track: track, slug: 'bob', prerequisites: []
    concept_exercise_strings = create :concept_exercise, track: track, slug: 'strings', prerequisites: []
    create :exercise_prerequisite, exercise: concept_exercise_strings
    user = create :user
    mentor = create :user

    # User joins the track
    # Check its retrieved correctly.
    ut = User::JoinTrack.call(user, track)
    assert_equal ut, UserTrack.for!(user, track)

    # Check we only have basics to start with
    assert_equal [concept_exercise_basics], ut.available_concept_exercises

    # Start the exercise and get a solution
    basics_solution = User::StartExercise.call(ut, concept_exercise_basics)

    # Submit an iteration
    Iteration::UploadWithExercise.stubs(:call)
    Iteration::UploadForStorage.stubs(:call)
    basics_iteration_1 =
      Iteration::Create.call(
        basics_solution,
        [{ filename: 'basics.rb', content: 'my code' }]
      )

    # Simulate a test run being returned
    # It should pass
    Iteration::TestRun::Process.call(
      basics_iteration_1.uuid,
      200,
      'success',
      {
        status: :pass, message: nil, tests: [{ name: 'test1', status: 'pass' }]
      }
    )
    assert basics_iteration_1.reload.tests_passed?

    # Simulate an analysis being returned
    # It should be inconclusive
    Iteration::Analysis::Process.call(
      basics_iteration_1.uuid,
      200,
      'success',
      { status: :inconclusive, comments: [] }
    )
    assert basics_iteration_1.reload.analysis_inconclusive?

    # Create a representation with feedback that should be given
    # It should approve with comment
    exercise_representation =
      create :exercise_representation,
             exercise: concept_exercise_basics,
             exercise_version: 15,
             ast_digest: Iteration::Representation.digest_ast('some ast'),
             action: :approve,
             feedback_markdown: "Fantastic Work!!",
             feedback_author: mentor
    Iteration::Representation::Process.call(
      basics_iteration_1.uuid,
      200,
      'success',
      'some ast'
    )
    assert basics_iteration_1.reload.representation_approved?
    assert_equal 1, basics_iteration_1.discussion_posts.size
    assert_equal mentor, basics_iteration_1.discussion_posts.first.user
    assert_equal "Fantastic Work!!", basics_iteration_1.discussion_posts.first.content_markdown
  end
end
