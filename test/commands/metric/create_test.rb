require "test_helper"

class Metric::CreateTest < ActiveSupport::TestCase
  test "creates metric" do
    freeze_time do
      occurred_at = Time.current - 2.seconds
      issue = create :github_issue
      track = create :track
      user = create :user

      Metric::Create.(:open_issue, occurred_at, track:, user:, issue:)

      assert_equal 1, Metric.count
      metric = Metric.last

      assert_equal occurred_at, metric.occurred_at
      assert_equal Time.current, metric.created_at
      assert_equal Time.current, metric.updated_at
      assert_equal track, metric.track
      assert_equal user, metric.user
    end
  end

  test "creates metric with remote ip can be matched to country code" do
    issue = create :github_issue
    track = create :track
    user = create :user
    remote_ip = '127.0.0.1'
    country_code = 'US'

    Geocoder::Lookup::Test.add_stub(remote_ip, [{ 'country_code' => country_code }])

    Metric::Create.(:open_issue, Time.current, remote_ip:, track:, user:, issue:)

    assert_equal 1, Metric.count
    assert_equal country_code, Metric.last.country_code
  end

  test "creates metric with remote ip cannot be matched to country code" do
    issue = create :github_issue
    track = create :track
    user = create :user
    remote_ip = '127.0.0.1'

    Geocoder::Lookup::Test.add_stub(remote_ip, [])

    Metric::Create.(:open_issue, Time.current, remote_ip:, track:, user:, issue:)

    assert_equal 1, Metric.count
    assert_nil Metric.last.country_code
  end

  test "creates metric with remote ip is nil" do
    action = :open_issue
    issue = create :github_issue
    occurred_at = Time.current - 2.seconds

    Metric::Create.(action, occurred_at, remote_ip: nil, issue:)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal occurred_at, metric.occurred_at
    assert_nil metric.country_code
  end

  test "creates metric without remote ip" do
    action = :open_issue
    issue = create :github_issue
    occurred_at = Time.current - 2.seconds

    Metric::Create.(action, occurred_at, issue:)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal occurred_at, metric.occurred_at
    assert_nil metric.country_code
  end

  test "creates metric without track or user" do
    action = :open_issue
    issue = create :github_issue
    occurred_at = Time.current - 2.seconds

    Metric::Create.(action, occurred_at, issue:)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal occurred_at, metric.occurred_at
    assert_nil metric.track
    assert_nil metric.user
  end
end
