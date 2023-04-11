require 'test_helper'

class SerializeSolutionsTest < ActiveSupport::TestCase
  test "basic to_hash" do
    user = create :user
    solution = create(:practice_solution, published_at: Time.current - 1.week, user:)
    create(:submission, solution:)
    user_track = create :user_track, user:, track: solution.track

    expected = [SerializeSolution.(solution, user_track:)]

    assert_equal expected, SerializeSolutions.(Solution.all, user)
  end

  test "doesn't use n+1 notification checks" do
    user = create :user
    track = create :track

    # One with notifications and one without
    exercise_1 = create(:practice_exercise, track:)
    exercise_2 = create(:practice_exercise, track:)
    solution_1 = create(:practice_solution, exercise: exercise_1, user:)
    solution_2 = create(:practice_solution, exercise: exercise_2, user:)
    discussion = create(:mentor_discussion, solution: solution_1)
    create :mentor_started_discussion_notification, user:, params: { discussion: }, status: :unread

    user_track = create(:user_track, user:, track:)
    assert user_track.exercise_has_notifications?(exercise_1)
    refute user_track.exercise_has_notifications?(exercise_2)

    # Sanity check the individual serializer uses it
    UserTrack.any_instance.expects(:exercise_has_notifications?).twice
    SerializeSolution.(solution_1, user_track:)
    SerializeSolution.(solution_2, user_track:)

    UserTrack.any_instance.expects(:exercise_has_notifications?).never
    data = SerializeSolutions.(Solution.all, user)
    assert data[0][:has_notifications]
    refute data[1][:has_notifications]
  end
end
