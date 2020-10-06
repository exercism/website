require 'test_helper'

class Submission::Analysis::ProcessTest < ActiveSupport::TestCase
  test "creates analysis record" do
    submission = create :submission
    ops_status = 200
    ops_message = "some ops message"
    status = "foobar"
    comments = [{ 'foo' => 'bar' }]
    data = { 'status' => status, 'comments' => comments }

    Submission::Analysis::Process.(submission.uuid, ops_status, ops_message, data)

    assert_equal 1, submission.reload.analyses.size
    analysis = submission.reload.analyses.first

    assert_equal ops_status, analysis.ops_status
    assert_equal ops_message, analysis.ops_message
    assert_equal status.to_sym, analysis.status
    assert_equal comments, analysis.send(:comments)
    assert_equal data, analysis.send(:data)
  end

  test "handle ops error" do
    submission = create :submission
    data = { 'status' => :pass, 'comments' => [] }
    Submission::Analysis::Process.(submission.uuid, 500, "", data)

    assert submission.reload.analysis_exceptioned?
  end

  test "handle approval" do
    submission = create :submission
    data = { 'status' => :approve, 'comments' => [] }
    Submission::Analysis::Process.(submission.uuid, 200, "", data)

    assert submission.reload.analysis_approved?
  end

  test "handle inconclusive" do
    submission = create :submission
    data = { 'status' => :refer_to_mentor, 'comments' => [] }
    Submission::Analysis::Process.(submission.uuid, 200, "", data)

    assert submission.reload.analysis_inconclusive?
  end

  test "handle disapproval" do
    submission = create :submission
    data = { 'status' => :disapprove, 'comments' => [] }
    Submission::Analysis::Process.(submission.uuid, 200, "", data)

    assert submission.reload.analysis_disapproved?
  end

  test "handle ambiguous" do
    submission = create :submission
    data = { 'status' => :ambiguous, 'comments' => [] }
    Submission::Analysis::Process.(submission.uuid, 200, "", data)

    assert submission.reload.analysis_exceptioned?
  end

  test "broadcast" do
    submission = create :submission
    data = { 'status' => :approve, 'comments' => [] }

    SubmissionChannel.expects(:broadcast!).with(submission)
    SubmissionsChannel.expects(:broadcast!).with(submission.solution)

    Submission::Analysis::Process.(submission.uuid, 200, "", data)
  end
end
