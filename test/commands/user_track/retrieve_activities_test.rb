require 'test_helper'

class UserTrack::RetrieveActivitiesTest < ActiveSupport::TestCase
  test "orders correctly" do
    user = create :user
    track = create :track
    user_track = create :user_track, user: user, track: track

    first = create :started_exercise_user_activity, user: user, track: track
    second = create :started_exercise_user_activity, user: user, track: track

    activities = UserTrack::RetrieveActivities.(user_track)
    assert_equal [second, first], activities
  end

  test "filters by user and track" do
    user = create :user
    track = create :track
    user_track = create :user_track, user: user, track: track

    valid = create :started_exercise_user_activity, user: user, track: track
    create :started_exercise_user_activity, user: user
    create :started_exercise_user_activity, track: track

    activities = UserTrack::RetrieveActivities.(user_track)
    assert_equal [valid], activities
  end

  test "groups by grouping_key and returns most recent" do
    user = create :user
    track = create :track
    user_track = create :user_track, user: user, track: track
    exercise_1 = create :concept_exercise, track: track
    exercise_2 = create :concept_exercise, track: track

    one_started = create :started_exercise_user_activity, user: user, track: track, params: { exercise: exercise_1 }
    create :started_exercise_user_activity, user: user, params: { exercise: exercise_2 }
    two_submitted = create :submitted_iteration_user_activity,
      user: user,
      track: track,
      params: { exercise: exercise_2,
                iteration: create(:iteration,
                  exercise: exercise_2) }

    activities = UserTrack::RetrieveActivities.(user_track)
    assert_equal [two_submitted, one_started], activities
  end
end
