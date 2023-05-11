require "test_helper"

class Mentor::UpdateSatisfactionPercentageTest < ActiveSupport::TestCase
  test "updates mentor_satisfaction_percentage" do
    mentor = create :user
    mentor.mentor_satisfaction_percentage # Cache it

    # Sanity check
    assert_nil mentor.mentor_satisfaction_percentage

    perform_enqueued_jobs do
      create :mentor_discussion, mentor:, status: :finished, rating: :great
      create :mentor_discussion, mentor:, status: :finished, rating: :problematic
      create :mentor_discussion, mentor:, status: :mentor_finished, rating: :acceptable
      create :mentor_discussion, mentor:, status: :mentor_finished, rating: :good
    end

    Mentor::UpdateSatisfactionPercentage.(mentor)

    assert_equal 75, mentor.reload.mentor_satisfaction_percentage
  end

  test "mentor_satisfaction_percentage is rounded up" do
    mentor = create :user
    mentor.mentor_satisfaction_percentage # Cache it

    # Sanity check
    assert_nil mentor.mentor_satisfaction_percentage

    perform_enqueued_jobs do
      create :mentor_discussion, mentor:, status: :finished, rating: :great
      create :mentor_discussion, mentor:, status: :mentor_finished, rating: :problematic
      create :mentor_discussion, mentor:, status: :finished, rating: :problematic
    end

    Mentor::UpdateSatisfactionPercentage.(mentor)

    assert_equal 34, mentor.reload.mentor_satisfaction_percentage
  end

  test "copes with zero" do
    mentor = create :user
    assert_nil mentor.mentor_satisfaction_percentage # Sanity check

    Mentor::UpdateSatisfactionPercentage.(mentor)

    assert_nil mentor.reload.mentor_satisfaction_percentage
  end
end
