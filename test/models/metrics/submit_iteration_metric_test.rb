require "test_helper"

class Metrics::SubmitIterationTest < ActiveSupport::TestCase
  test "create metric" do
    freeze_time do
      track = create :track, id: 2
      user = create :user, id: 3
      iteration = create :iteration, id: 4
      occurred_at = Time.current - 5.seconds
      request_context = { remote_ip: '127.0.0.1' }

      metric = Metric::Create.(:submit_iteration, occurred_at, iteration:, track:, user:, request_context:)

      assert_instance_of Metrics::SubmitIterationMetric, metric
      assert_equal occurred_at, metric.occurred_at
      assert_equal user, metric.user
      assert_equal track, metric.track
      assert_equal 'US', metric.country_code
      assert_equal "SubmitIterationMetric|4", metric.uniqueness_key
    end
  end

  test "correctly sets params" do
    freeze_time do
      iteration = create :iteration, id: 4

      metric = Metric::Create.(:submit_iteration, Time.current, iteration:)

      expected = { "iteration" => "gid://website/Iteration/4" }
      assert_equal expected, metric.params
    end
  end

  test "uniqueness_key is unique per iteration" do
    uniqueness_keys = Array.new(10) do
      iteration = create :iteration
      Metric::Create.(:submit_iteration, Time.current, iteration:)
    end

    assert_equal uniqueness_keys.uniq.size, uniqueness_keys.size
  end

  test "idempotent" do
    iteration = create :iteration

    assert_idempotent_command do
      Metric::Create.(:submit_iteration, Time.utc(2012, 7, 25), iteration:)
    end
  end
end
