require "test_helper"

class Mentor::UpdateSatisfactionRatingTest < ActiveSupport::TestCase
  test "updates mentor_satisfaction_percentage" do
    mentor = create :user

    create :mentor_discussion, mentor:, status: :finished, rating: :great
    create :mentor_discussion, mentor:, status: :finished, rating: :problematic
    create :mentor_discussion, mentor:, status: :mentor_finished, rating: :acceptable
    create :mentor_discussion, mentor:, status: :mentor_finished, rating: :good

    # Sanity check
    assert_nil mentor.mentor_satisfaction_percentage

    Mentor::UpdateSatisfactionRating.(mentor)

    assert_equal 75, mentor.reload.mentor_satisfaction_percentage
  end

  test "mentor_satisfaction_percentage is rounded up" do
    mentor = create :user

    create :mentor_discussion, mentor:, status: :finished, rating: :great
    create :mentor_discussion, mentor:, status: :mentor_finished, rating: :problematic
    create :mentor_discussion, mentor:, status: :finished, rating: :problematic

    # Sanity check
    assert_nil mentor.mentor_satisfaction_percentage

    Mentor::UpdateSatisfactionRating.(mentor)

    assert_equal 34, mentor.reload.mentor_satisfaction_percentage
  end

  test "updates supermentor role" do
    mentor = create :user
    create :user_track_mentorship, user: mentor

    99.times do
      create :mentor_discussion, :finished, mentor:, rating: :great
    end

    create :mentor_discussion, :finished, mentor:, rating: :great
    perform_enqueued_jobs

    Mentor::UpdateSatisfactionRating.(mentor)

    assert mentor.reload.supermentor?
  end

  test "copes with zero" do
    mentor = create :user
    assert_nil mentor.mentor_satisfaction_percentage # Sanity check

    Mentor::UpdateSatisfactionRating.(mentor)

    assert_nil mentor.reload.mentor_satisfaction_percentage
  end
end
