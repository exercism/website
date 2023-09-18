require "test_helper"

class Metrics::RequestPrivateMentoringTest < ActiveSupport::TestCase
  test "create metric" do
    freeze_time do
      track = create :track, id: 2
      user = create :user, id: 3
      request = create :mentor_request, id: 4
      occurred_at = Time.current - 5.seconds
      request_context = { remote_ip: '127.0.0.1' }

      metric = Metric::Create.(:request_private_mentoring, occurred_at, request:, track:, user:, request_context:)

      assert_instance_of Metrics::RequestPrivateMentoringMetric, metric
      assert_equal occurred_at, metric.occurred_at
      assert_equal user, metric.user
      assert_equal track, metric.track
      assert_equal "RequestPrivateMentoringMetric|4", metric.uniqueness_key
    end
  end

  test "correctly sets params" do
    freeze_time do
      request = create :mentor_request, id: 4

      metric = Metric::Create.(:request_private_mentoring, Time.current, request:)

      expected = { "request" => "gid://website/Mentor::Request/4" }
      assert_equal expected, metric.params
    end
  end

  test "uniqueness_key is unique per request" do
    uniqueness_keys = Array.new(10) do
      request = create :mentor_request
      Metric::Create.(:request_private_mentoring, Time.current, request:)
    end

    assert_equal uniqueness_keys.uniq.size, uniqueness_keys.size
  end

  test "idempotent" do
    request = create :mentor_request

    assert_idempotent_command do
      Metric::Create.(:request_private_mentoring, Time.utc(2012, 7, 25), request:)
    end
  end
end
