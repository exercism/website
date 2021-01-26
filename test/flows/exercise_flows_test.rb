require 'test_helper'

class ExerciseFlowsTest < ActiveSupport::TestCase
  test 'start a track and submit an exercise' do
    track = create :track, slug: "csharp"
    concept_exercise_basics = create :concept_exercise, track: track, slug: 'datetime', prerequisites: []
    concept_exercise_strings = create :concept_exercise, track: track, slug: 'strings', prerequisites: []
    create :exercise_prerequisite, exercise: concept_exercise_strings
    user = create :user
    mentor = create :user

    # User joins the track
    # Check its retrieved correctly.
    ut = UserTrack::Create.(user, track)
    assert_equal ut, UserTrack.for!(user, track)

    # Check we only have basics to start with
    assert_equal [concept_exercise_basics], ut.available_concept_exercises

    # Start the exercise and get a solution
    basics_solution = Solution::Create.(user, concept_exercise_basics)

    # Submit an submission
    ToolingJob::Create.stubs(:call)
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
      exercise: concept_exercise_basics,
      ast_digest: Submission::Representation.digest_ast('some ast'),
      feedback_markdown: "Fantastic Work!!",
      feedback_author: mentor

    job = create_representer_job!(
      basics_submission_1,
      execution_status: 200,
      ast: 'some ast',
      mapping: { 'some' => 'mapping' }
    )
    Submission::Representation::Process.(job)
    assert basics_submission_1.reload.representation_generated?
    assert basics_submission_1.automated_feedback
    assert_equal mentor.name, basics_submission_1.automated_feedback[:mentor][:author][:name]
    assert_equal "<p>Fantastic Work!!</p>\n", basics_submission_1.automated_feedback[:mentor][:html]
  end
end
