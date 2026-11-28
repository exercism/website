require 'test_helper'

class Submission::Representation::InitTest < ActiveSupport::TestCase
  test "queues Generate for the submission" do
    submission = create :submission

    Submission::Representation::Generate.expects(:defer).with(submission, submission.git_sha, reason: nil)

    Submission::Representation::Init.(submission)
    assert_equal 'queued', submission.representation_status
  end

  test "honours arguments for exercise reruns" do
    submission = create :submission

    Submission::Representation::Generate::InBackground.expects(:defer).with(submission, "foobar", reason: :update)

    Submission::Representation::Init.(submission, type: :exercise, git_sha: "foobar", run_in_background: true)
    assert_equal 'not_queued', submission.representation_status
  end

  test "runs submission reruns in the background" do
    submission = create :submission

    Submission::Representation::Generate::InBackground.expects(:defer).with(submission, submission.git_sha, reason: nil)

    Submission::Representation::Init.(submission, run_in_background: true)
    assert_equal 'queued', submission.representation_status
  end

  test "status is set before the job runs" do
    submission = create :submission
    create(:submission_file, submission:)
    stub_inspector!

    perform_enqueued_jobs do
      Submission::Representation::Init.(submission)
    end

    assert submission.reload.representation_generated?
  end
end
