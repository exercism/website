require 'test_helper'

class Submission::Analysis::ProcessTest < ActiveSupport::TestCase
  test "creates analysis record" do
    submission = create :submission
    ops_status = 200
    status = "foobar"
    comments = [{ 'foo' => 'bar' }]
    data = { 'status' => status, 'comments' => comments }

    job = create_analyzer_job!(submission, execution_status: ops_status, data: data)
    Submission::Analysis::Process.(job)

    analysis = submission.reload.analysis

    assert_equal job.id, analysis.tooling_job_id
    assert_equal ops_status, analysis.ops_status
    assert_equal status.to_sym, analysis.status
    assert_equal comments, analysis.send(:comments)
    assert_equal data, analysis.send(:data)
  end

  test "handle ops error" do
    submission = create :submission
    data = { 'status' => :pass, 'comments' => [] }
    job = create_analyzer_job!(submission, execution_status: 500, data: data)
    Submission::Analysis::Process.(job)

    assert submission.reload.analysis_exceptioned?
  end

  test "handle approval" do
    submission = create :submission
    data = { 'status' => :approve, 'comments' => [] }
    job = create_analyzer_job!(submission, execution_status: 200, data: data)
    Submission::Analysis::Process.(job)

    assert submission.reload.analysis_approved?
  end

  test "handle inconclusive" do
    submission = create :submission
    data = { 'status' => :refer_to_mentor, 'comments' => [] }
    job = create_analyzer_job!(submission, execution_status: 200, data: data)
    Submission::Analysis::Process.(job)

    assert submission.reload.analysis_inconclusive?
  end

  test "handle disapproval" do
    submission = create :submission
    data = { 'status' => :disapprove, 'comments' => [] }
    job = create_analyzer_job!(submission, execution_status: 200, data: data)
    Submission::Analysis::Process.(job)

    assert submission.reload.analysis_disapproved?
  end

  test "handle ambiguous" do
    submission = create :submission
    data = { 'status' => :ambiguous, 'comments' => [] }
    job = create_analyzer_job!(submission, execution_status: 200, data: data)
    Submission::Analysis::Process.(job)

    assert submission.reload.analysis_exceptioned?
  end

  test "broadcast" do
    submission = create :submission
    data = { 'status' => :approve, 'comments' => [] }

    SubmissionChannel.expects(:broadcast!).with(submission)
    SubmissionsChannel.expects(:broadcast!).with(submission.solution)

    job = create_analyzer_job!(submission, execution_status: 200, data: data)
    Submission::Analysis::Process.(job)
  end
end
