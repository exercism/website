require 'test_helper'

class ExerciseFlowsTest < ActiveSupport::TestCase
  test 'start a track and submit an exercise' do
    track = create :track
    concept = create :concept
    concept_exercise_lasagna = create :concept_exercise, track:, slug: 'lasagna', prerequisites: []
    concept_exercise_strings = create :concept_exercise, track:, slug: 'strings', prerequisites: []
    concept_exercise_lasagna.taught_concepts << concept
    concept_exercise_strings.prerequisites << concept
    user = create :user
    mentor = create :user

    # Hello world is already completed.
    # We might wnat to change this for hte context of this test.
    create(:hello_world_solution, :completed, track:, user:)

    # User joins the track
    # Check it's retrieved correctly.
    ut = UserTrack::Create.(user, track)
    assert_equal ut, UserTrack.for!(user, track)

    # Check we only have basics to start with
    assert_equal [concept_exercise_lasagna], ut.unlocked_concept_exercises

    # Start the exercise and get a solution
    basics_solution = Solution::Create.(user, concept_exercise_lasagna)

    # Submit an submission
    basics_submission_1 = Submission::Create.(
      basics_solution,
      [{ filename: 'basics.rb', content: 'my code' }],
      :cli
    )

    # Simulate a test run being returned
    # It should pass
    job = create_test_runner_job!(
      basics_submission_1,
      execution_status: 200,
      results: {
        status: :pass, message: nil, tests: [{ name: 'test1', status: 'pass' }]
      }
    )
    Submission::TestRun::Process.(job)
    assert basics_submission_1.reload.tests_passed?

    # Simulate an analysis being returned
    job = create_analyzer_job!(
      basics_submission_1,
      execution_status: 200,
      data: { status: :refer_to_mentor, comments: [] }
    )
    Submission::Analysis::Process.(job)
    assert basics_submission_1.reload.analysis_completed?

    # Create a representation with feedback that should be given
    # It should approve with comment
    create :exercise_representation,
      exercise: concept_exercise_lasagna,
      ast_digest: Submission::Representation.digest_ast('some ast'),
      feedback_markdown: "Fantastic Work!!",
      feedback_author: mentor,
      feedback_type: :actionable

    job = create_representer_job!(
      basics_submission_1,
      execution_status: 200,
      ast: 'some ast',
      mapping: { 'some' => 'mapping' }
    )
    Submission::Representation::Process.(job)
    assert basics_submission_1.reload.representation_generated?
    assert basics_submission_1.representer_feedback
    assert_equal mentor.name, basics_submission_1.representer_feedback[:author][:name]
    assert_equal "<p>Fantastic Work!!</p>\n", basics_submission_1.representer_feedback[:html]
  end
end
