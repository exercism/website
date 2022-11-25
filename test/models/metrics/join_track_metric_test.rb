require "test_helper"

class Metrics::JoinTrackMetricTest < ActiveSupport::TestCase
  test "create metric" do
    freeze_time do
      track = create :track, id: 2
      user = create :user, id: 3
      user_track = create :user_track, user: user, track: track, id: 4
      occurred_at = Time.current - 5.seconds

      metric = Metric::Create.(:join_track, occurred_at, user_track:, track:, user:)

      assert_equal Metrics::JoinTrackMetric, metric.class
      assert_equal occurred_at, metric.occurred_at
      assert_equal user, metric.user
      assert_equal track, metric.track
      assert_equal "JoinTrackMetric|4", metric.uniqueness_key
    end
  end

  test "correctly sets params" do
    freeze_time do
      user_track = create :user_track, id: 4

      metric = Metric::Create.(:join_track, Time.current, user_track:)

      expected = { "user_track" => "gid://website/UserTrack/4" }
      assert_equal expected, metric.params
    end
  end

  test "uniqueness_key is unique per issue" do
    uniqueness_keys = Array.new(10) do
      issue = create :github_issue, :random
      Metric::Create.(:open_issue, Time.current, issue:)
    end

    assert_equal uniqueness_keys.uniq.size, uniqueness_keys.size
  end

  test "idempotent" do
    issue = create :github_issue

    assert_idempotent_command do
      Metric::Create.(:open_issue, Time.utc(2012, 7, 25), issue:)
    end
  end
end
