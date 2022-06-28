require "test_helper"

class Metric::CreateTest < ActiveSupport::TestCase
  test "creates metric" do
    freeze_time do
      action = :request_mentoring
      occurred_at = Time.current - 2.seconds
      track = create :track
      user = create :user

      Metric::Create.(action, occurred_at, track:, user:)

      assert_equal 1, Metric.count
      metric = Metric.last

      assert_equal action, metric.metric_action
      assert_equal occurred_at, metric.occurred_at
      assert_equal Time.current, metric.created_at
      assert_equal Time.current, metric.updated_at
      assert_equal track, metric.track
      assert_equal user, metric.user
    end
  end

  test "creates metric without track or user" do
    action = :request_mentoring
    occurred_at = Time.current - 2.seconds

    Metric::Create.(action, occurred_at, track: nil)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal action, metric.metric_action
    assert_equal occurred_at, metric.occurred_at
    assert_nil metric.track
    assert_nil metric.user
  end
end
