require 'test_helper'

class Submission::CreateTest < ActiveSupport::TestCase
  test "creates major submission" do
    filename_1 = "subdir/foobar.rb"
    content_1 = "'I think' = 'I am'"
    digest_1 = Digest::SHA1.hexdigest(content_1)

    filename_2 = "barfood.rb"
    content_2 = "something = :else"
    digest_2 = Digest::SHA1.hexdigest(content_2)

    files = [
      { filename: filename_1, content: content_1 },
      { filename: filename_2, content: content_2 }
    ]

    Submission::UploadWithExercise.expects(:call)
    Submission::TestRun::Init.expects(:call)
    Submission::Analysis::Init.expects(:call)
    Submission::Representation::Init.expects(:call)

    solution = create :concept_solution
    submission = Submission::Create.(solution, files, :cli, true)

    # Check db record is setup correctly
    assert submission.persisted?
    assert_equal submission.solution, solution
    assert :pending, submission.tests_status
    assert :pending, submission.representation_status
    assert :pending, submission.analysis_status

    # Check files are set up correctly
    assert_equal 2, submission.files.count

    first_file = submission.files.first
    assert_equal filename_1, first_file.filename
    assert_equal digest_1, first_file.digest
    assert_equal content_1, first_file.content

    second_file = submission.files.last
    assert_equal filename_2, second_file.filename
    assert_equal digest_2, second_file.digest
    assert_equal content_2, second_file.content
  end

  test "does not use analysis or representation for minor submission" do
    solution = create :concept_solution
    files = [
      { filename: "subdir/foobar.rb", content: "'I think' = 'I am'" }
    ]

    Submission::UploadWithExercise.expects(:call)
    Submission::TestRun::Init.expects(:call)
    Submission::Analysis::Init.expects(:call).never
    Submission::Representation::Init.expects(:call).never

    submission = Submission::Create.(solution, files, :cli, false)

    # Check they are correctly marked as cancelled
    assert :pending, submission.tests_status
    assert :cancelled, submission.representation_status
    assert :cancelled, submission.analysis_status
  end

  test "guards against duplicates" do
    solution = create :concept_solution
    filename_1 = "subdir/foobar.rb"
    content_1 = "'I think' = 'I am'"

    filename_2 = "barfood.rb"
    content_2 = "something = :else"

    files = [
      { filename: filename_1, content: content_1 },
      { filename: filename_2, content: content_2 }
    ]

    # We'll call upload so stub it
    Submission::UploadWithExercise.stubs(:call)
    ToolingJob::Create.stubs(:call)

    # Do it once successfully
    Submission::Create.(solution, files, :cli, true)

    # The second time *in a row* it should fail
    assert_raises DuplicateSubmissionError do
      Submission::Create.(solution, files, :cli, true)
    end

    # Submit something different
    Submission::Create.(solution, [files.first], :cli, true)

    # The duplicate should now succeed
    Submission::Create.(solution, files, :cli, true)
  end

  test "updates solution status" do
    files = [{ filename: 'foo.bar', content: "foobar" }]

    solution = create :concept_solution
    assert_equal 'pending', solution.status
    assert solution.pending?

    Submission::UploadWithExercise.stubs(:call)
    ToolingJob::Create.stubs(:call)
    Submission::Create.(solution, [files.first], :cli, true)
    assert_equal 'submitted', solution.reload.status
  end

  test "award rookie badge job is enqueued" do
    # Generic setup
    files = [{ filename: 'foo.bar', content: "foobar" }]
    Submission::UploadWithExercise.stubs(:call)
    ToolingJob::Create.stubs(:call)

    # Create user and solution
    user = create :user
    solution = create :concept_solution, user: user

    assert_enqueued_with(job: AwardBadgeJob, args: [user, :rookie]) do
      Submission::Create.(solution, [files.first], :cli, true)
    end
  end
end
