require "test_helper"

class Mentor::UpdateNumSolutionsMentoredTest < ActiveSupport::TestCase
  test "recalculates num_solutions_mentored" do
    mentor = create :user
    mentor.num_solutions_mentored # Cache it

    # Sanity check
    assert_equal 0, mentor.num_solutions_mentored

    perform_enqueued_jobs do
      create :mentor_discussion, mentor:, status: :finished
      create :mentor_discussion, mentor:, status: :mentor_finished
      create :mentor_discussion, mentor:, status: :mentor_finished
    end

    Mentor::UpdateNumSolutionsMentored.(mentor)

    assert_equal 3, mentor.reload.num_solutions_mentored
  end
end
