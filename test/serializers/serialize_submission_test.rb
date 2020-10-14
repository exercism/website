require 'test_helper'

class SerializeSubmissionTest < ActiveSupport::TestCase
  test "test submission" do
    submission = create :submission, tests_status: :failed
    expected = {
      uuid: submission.uuid,
      tests_status: 'failed'
    }
    actual = SerializeSubmission.(submission)
    assert_equal expected, actual
  end
end
