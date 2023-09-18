require 'test_helper'

class Submission::CreateTest < ActiveSupport::TestCase
  test "creates submission" do
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

    solution = create :concept_solution
    submission = Submission::Create.(solution, files, :cli)

    # Check db record is setup correctly
    assert submission.persisted?
    assert_equal submission.solution, solution

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

    # Do it once successfully
    Submission::Create.(solution, files, :cli)

    # The second time *in a row* it should fail
    assert_raises DuplicateSubmissionError do
      Submission::Create.(solution.reload, files, :cli)
    end

    # Submit something different
    Submission::Create.(solution.reload, [files.first], :cli)

    # The duplicate should now succeed
    Submission::Create.(solution.reload, files, :cli)
  end

  test "awards rookie badge" do
    # Generic setup
    files = [{ filename: 'foo.bar', content: "foobar" }]

    # Create user and solution
    user = create :user
    solution = create(:concept_solution, user:)
    create(:iteration, solution:)
    refute user.badges.present?

    Submission::Create.(solution, files, :cli)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::RookieBadge
  end

  test "starts test run" do
    solution = create :concept_solution

    files = [{ filename: "subdir/foobar.rb", content: "'I think' = 'I am'" }]

    test_run_id = SecureRandom.uuid
    SecureRandom.stubs(uuid: test_run_id)
    Submission::TestRun::Init.expects(:call).with(anything)
    submission = Submission::Create.(solution, files, :cli)

    assert :queued, submission.tests_status
    assert :not_queued, submission.representation_status
    assert :not_queued, submission.analysis_status
  end

  test "adds metric" do
    files = [{ filename: "file1", content: "contents" }]
    solution = create :concept_solution

    submission = Submission::Create.(solution, files, :cli)
    perform_enqueued_jobs

    assert_equal 1, Metric.count
    metric = Metric.last
    assert_instance_of Metrics::SubmitSubmissionMetric, metric
    assert_equal submission.created_at, metric.occurred_at
    assert_equal submission, metric.submission
    assert_equal solution.track, metric.track
    assert_equal solution.user, metric.user
  end
end
