require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase
  test "statuses start at pending" do
    submission = create :submission
    assert submission.tests_pending?
    assert submission.representation_pending?
    assert submission.analysis_pending?
  end

  test "submissions get their solution's git data" do
    solution = create :concept_solution
    submission = create :submission, solution: solution

    assert_equal solution.git_sha, submission.git_sha
    assert_equal solution.git_slug, submission.git_slug
  end

  test "exercise_version" do
    submission = create :submission
    assert_equal '15.8.12', submission.exercise_version
  end
end
