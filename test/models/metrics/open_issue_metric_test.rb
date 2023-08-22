require "test_helper"

class Metrics::OpenIssueTest < ActiveSupport::TestCase
  test "create metric" do
    freeze_time do
      track = create :track, id: 2
      user = create :user, id: 3
      issue = create :github_issue, id: 4
      occurred_at = Time.current - 5.seconds

      metric = Metric::Create.(:open_issue, occurred_at, issue:, track:, user:)

      assert_instance_of Metrics::OpenIssueMetric, metric
      assert_equal occurred_at, metric.occurred_at
      assert_equal user, metric.user
      assert_equal track, metric.track
      assert_equal "OpenIssueMetric|4", metric.uniqueness_key
    end
  end

  test "correctly sets params" do
    freeze_time do
      issue = create :github_issue, id: 4

      metric = Metric::Create.(:open_issue, Time.current, issue:)

      expected = { "issue" => "gid://website/Github::Issue/4" }
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
