require "test_helper"

class Metric::CreateTest < ActiveSupport::TestCase
  test "creates metric" do
    freeze_time do
      occurred_at = Time.current - 2.seconds
      country_code = 'TO'
      issue = create :github_issue
      track = create :track
      user = create :user

      Metric::Create.(:open_issue, occurred_at, country_code, track:, user:, issue:)

      assert_equal 1, Metric.count
      metric = Metric.last

      assert_equal occurred_at, metric.occurred_at
      assert_equal country_code, metric.country_code
      assert_equal Time.current, metric.created_at
      assert_equal Time.current, metric.updated_at
      assert_equal track, metric.track
      assert_equal user, metric.user
    end
  end

  test "creates metric with country code is nil" do
    action = :open_issue
    issue = create :github_issue
    occurred_at = Time.current - 2.seconds
    country_code = nil

    Metric::Create.(action, occurred_at, country_code, issue:)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal occurred_at, metric.occurred_at
    assert_nil metric.country_code
  end

  test "creates metric without track or user" do
    action = :open_issue
    issue = create :github_issue
    occurred_at = Time.current - 2.seconds
    country_code = 'Ve'

    Metric::Create.(action, occurred_at, country_code, issue:)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal occurred_at, metric.occurred_at
    assert_nil metric.track
    assert_nil metric.user
  end
end
