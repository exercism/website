require "test_helper"

class CommunityVideoTest < ActiveSupport::TestCase
  test "updates has_approaches for new exercise video" do
    exercise = create :practice_exercise, slug: 'leap'

    perform_enqueued_jobs do
      create :community_video, exercise:, status: :pending
    end

    refute exercise.reload.has_approaches?
  end

  test "updates has_approaches for exercise video with status changed" do
    exercise = create :practice_exercise, slug: 'leap'
    video = create :community_video, exercise:, status: :pending

    # Sanity check
    refute exercise.reload.has_approaches?

    perform_enqueued_jobs do
      video.update(status: :rejected)
    end

    refute exercise.reload.has_approaches?

    perform_enqueued_jobs do
      video.update(status: :approved)
    end

    assert exercise.reload.has_approaches?
  end
end
