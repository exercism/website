require 'test_helper'

class ExerciseFlowsTest < ActiveSupport::TestCase
  test 'start a track and submit an exercise that gets approved' do
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
    Submission::UploadWithExercise.stubs(:call)
    ToolingJob::Create.stubs(:call)
    basics_submission_1 = Submission::Create.(
      basics_solution,
      [{ filename: 'basics.rb', content: 'my code' }],
      :cli
    )

    # Simulate a test run being returned
    # It should pass
    Submission::TestRun::Process.(
      basics_submission_1.uuid,
      200,
      {
        status: :pass, message: nil, tests: [{ name: 'test1', status: 'pass' }]
      }
    )
    assert basics_submission_1.reload.tests_passed?

    # Simulate an analysis being returned
    # It should be inconclusive
    Submission::Analysis::Process.(
      basics_submission_1.uuid,
      200,
      { status: :refer_to_mentor, comments: [] }
    )
    assert basics_submission_1.reload.analysis_inconclusive?

    # Create a representation with feedback that should be given
    # It should approve with comment
    create :exercise_representation,
      exercise: concept_exercise_basics,
      exercise_version: 15,
      ast_digest: Submission::Representation.digest_ast('some ast'),
      action: :approve,
      feedback_markdown: "Fantastic Work!!",
      feedback_author: mentor
    Submission::Representation::Process.(
      basics_submission_1.uuid,
      200,
      'some ast',
      { 'some' => 'mapping' }
    )
    assert basics_submission_1.reload.representation_approved?
    assert_equal 1, basics_submission_1.discussion_posts.size
    assert_equal mentor, basics_submission_1.discussion_posts.first.user
    assert_equal "Fantastic Work!!", basics_submission_1.discussion_posts.first.content_markdown
  end
end
