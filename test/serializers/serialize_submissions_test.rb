require 'test_helper'

class SerializeSubmissionsTest < ActiveSupport::TestCase
  test "test submissions" do
    user = create :user
    solution = create(:concept_solution, user:)
    submission = create(:submission, tests_status: :failed, solution:)

    expected = [SerializeSubmission.(submission)]
    actual = SerializeSubmissions.(Submission.all)
    assert_equal expected, actual
  end

  test "returns [] if no solutons are passed in" do
    assert_empty SerializeSubmissions.([])
  end
end
