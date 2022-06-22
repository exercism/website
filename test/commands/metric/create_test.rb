require "test_helper"

class Metric::CreateTest < ActiveSupport::TestCase
  test "creates metric" do
    action = :request_mentoring
    created_at = Time.current - 2.seconds
    track = create :track
    user = create :user

    Metric::Create.(action, created_at, track:, user:)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal action, metric.metric_action
    assert_equal created_at, metric.created_at
    assert_equal track, metric.track
    assert_equal user, metric.user
  end

  test "creates metric without track or user" do
    action = :request_mentoring
    created_at = Time.current - 2.seconds

    Metric::Create.(action, created_at)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal action, metric.metric_action
    assert_equal created_at, metric.created_at
    assert_nil metric.track
    assert_nil metric.user
  end
end
