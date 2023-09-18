require "test_helper"

class UserTrack::CreateTest < ActiveSupport::TestCase
  test "creates user_track" do
    user = create :user
    track = create :track

    UserTrack::Create.(user, track)

    assert_equal 1, UserTrack.count
    ut = UserTrack.last

    assert_equal user, ut.user
    assert_equal track, ut.track
  end

  test "adds metric" do
    user = create :user
    track = create :track

    user_track = UserTrack::Create.(user, track)
    perform_enqueued_jobs

    assert_equal 1, Metric.count
    metric = Metric.last
    assert_instance_of Metrics::JoinTrackMetric, metric
    assert_equal user_track.created_at, metric.occurred_at
    assert_equal user_track, metric.user_track
    assert_equal track, metric.track
    assert_equal user, metric.user
  end

  test "idempotent" do
    user = create :user
    track = create :track

    assert_idempotent_command { UserTrack::Create.(user, track) }
  end
end
