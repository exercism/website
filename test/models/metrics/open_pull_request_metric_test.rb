require "test_helper"

class Metrics::OpenPullRequestTest < ActiveSupport::TestCase
  test "create metric" do
    freeze_time do
      track = create :track, id: 2
      user = create :user, id: 3
      pull_request = create :github_pull_request, id: 4
      occurred_at = Time.current - 5.seconds

      metric = Metric::Create.(:open_pull_request, occurred_at, pull_request:, track:, user:)

      assert_instance_of Metrics::OpenPullRequestMetric, metric
      assert_equal occurred_at, metric.occurred_at
      assert_equal user, metric.user
      assert_equal track, metric.track
      assert_equal "OpenPullRequestMetric|4", metric.uniqueness_key
    end
  end

  test "correctly sets params" do
    freeze_time do
      pull_request = create :github_pull_request, id: 4

      metric = Metric::Create.(:open_pull_request, Time.current, pull_request:)

      expected = { "pull_request" => "gid://website/Github::PullRequest/4" }
      assert_equal expected, metric.params
    end
  end

  test "uniqueness_key is unique per pull_request" do
    uniqueness_keys = Array.new(10) do
      pull_request = create :github_pull_request, :random
      Metric::Create.(:open_pull_request, Time.current, pull_request:)
    end

    assert_equal uniqueness_keys.uniq.size, uniqueness_keys.size
  end

  test "idempotent" do
    pull_request = create :github_pull_request

    assert_idempotent_command do
      Metric::Create.(:open_pull_request, Time.utc(2012, 7, 25), pull_request:)
    end
  end
end
