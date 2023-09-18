require 'test_helper'

class Submission::SyncRepresentationStatusTest < ActiveSupport::TestCase
  test "returns false with no representation" do
    submission = create :submission
    refute Submission::SyncRepresentationStatus.(submission)
  end

  test "updates and returns true with exceptioned representation" do
    submission = create :submission
    create :submission_representation, submission:, ops_status: 500

    # Sanity
    assert_equal 'not_queued', submission.representation_status

    assert Submission::SyncRepresentationStatus.(submission)
    assert_equal 'exceptioned', submission.representation_status
  end

  test "updates and returns true with ok representation" do
    submission = create :submission
    create :submission_representation, submission:, ops_status: 200

    # Sanity
    assert_equal 'not_queued', submission.representation_status

    assert Submission::SyncRepresentationStatus.(submission)
    assert_equal 'generated', submission.representation_status
  end
end
