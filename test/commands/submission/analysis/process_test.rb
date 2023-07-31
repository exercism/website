require 'test_helper'

class Submission::Analysis::ProcessTest < ActiveSupport::TestCase
  test "creates analysis record" do
    submission = create :submission
    ops_status = 200
    comments = [{ 'foo' => 'bar' }]
    data = { 'comments' => comments }

    job = create_analyzer_job!(submission, execution_status: ops_status, data:)
    Submission::Analysis::Process.(job)

    analysis = submission.reload.analysis

    assert_equal job.id, analysis.tooling_job_id
    assert_equal ops_status, analysis.ops_status
    assert_equal data, analysis.send(:data)
  end

  test "handle ops error" do
    submission = create :submission
    data = { 'comments' => [] }
    job = create_analyzer_job!(submission, execution_status: 500, data:)
    Submission::Analysis::Process.(job)

    assert submission.reload.analysis_exceptioned?
  end

  test "handle completed" do
    submission = create :submission
    data = { 'comments' => [] }
    job = create_analyzer_job!(submission, execution_status: 200, data:)
    Submission::Analysis::Process.(job)

    assert submission.reload.analysis_completed?
  end

  test "broadcast without iteration" do
    submission = create :submission
    data = { 'comments' => [] }

    SubmissionChannel.expects(:broadcast!).with(submission)

    job = create_analyzer_job!(submission, execution_status: 200, data:)
    Submission::Analysis::Process.(job)
  end

  test "broadcast with iteration" do
    submission = create :submission
    iteration = create(:iteration, submission:)
    data = { 'comments' => [] }

    IterationChannel.expects(:broadcast!).with(iteration)
    SubmissionChannel.expects(:broadcast!).with(submission)

    job = create_analyzer_job!(submission, execution_status: 200, data:)
    Submission::Analysis::Process.(job)
  end
end
