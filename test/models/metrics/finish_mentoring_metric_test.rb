require "test_helper"

class Metrics::FinishMentoringTest < ActiveSupport::TestCase
  test "create metric" do
    freeze_time do
      track = create :track, id: 2
      user = create :user, id: 3
      discussion = create :mentor_discussion, id: 4
      occurred_at = Time.current - 5.seconds
      request_context = { remote_ip: '127.0.0.1' }

      metric = Metric::Create.(:finish_mentoring, occurred_at, discussion:, track:, user:, request_context:)

      assert_instance_of Metrics::FinishMentoringMetric, metric
      assert_equal occurred_at, metric.occurred_at
      assert_equal user, metric.user
      assert_equal track, metric.track
      assert_equal 'US', metric.country_code
      assert_equal "FinishMentoringMetric|4", metric.uniqueness_key
    end
  end

  test "correctly sets params" do
    freeze_time do
      discussion = create :mentor_discussion, id: 4

      metric = Metric::Create.(:finish_mentoring, Time.current, discussion:)

      expected = { "discussion" => "gid://website/Mentor::Discussion/4" }
      assert_equal expected, metric.params
    end
  end

  test "uniqueness_key is unique per discussion" do
    uniqueness_keys = Array.new(10) do
      discussion = create :mentor_discussion
      Metric::Create.(:finish_mentoring, Time.current, discussion:)
    end

    assert_equal uniqueness_keys.uniq.size, uniqueness_keys.size
  end

  test "idempotent" do
    discussion = create :mentor_discussion

    assert_idempotent_command do
      Metric::Create.(:finish_mentoring, Time.utc(2012, 7, 25), discussion:)
    end
  end
end
