require "test_helper"

class Mentor::UpdateNumSolutionsMentoredTest < ActiveSupport::TestCase
  test "recalculates num_solutions_mentored" do
    mentor = create :user
    mentor.num_solutions_mentored # Cache it

    # Sanity check
    assert_equal 0, mentor.num_solutions_mentored

    create(:mentor_discussion, mentor:)
    Mentor::UpdateNumSolutionsMentored.(mentor)
    assert_equal 0, mentor.reload.num_solutions_mentored

    create :mentor_discussion, mentor:, status: :mentor_finished
    Mentor::UpdateNumSolutionsMentored.(mentor)
    assert_equal 0, mentor.reload.num_solutions_mentored

    create :mentor_discussion, mentor:, status: :finished
    create :mentor_discussion, mentor:, status: :finished
    Mentor::UpdateNumSolutionsMentored.(mentor)
    assert_equal 2, mentor.reload.num_solutions_mentored
  end
end
