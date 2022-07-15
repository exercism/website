require "test_helper"

class Metrics::RequestMentoringTest < ActiveSupport::TestCase
  test "create metric" do
    freeze_time do
      track = create :track, id: 2
      user = create :user, id: 3
      request = create :mentor_request, id: 4
      occurred_at = Time.current - 5.seconds

      metric = Metric::Create.(:request_mentoring, occurred_at, request:, track:, user:)

      assert_equal Metrics::RequestMentoringMetric, metric.class
      assert_equal occurred_at, metric.occurred_at
      assert_equal user, metric.user
      assert_equal track, metric.track
      assert_equal "RequestMentoringMetric|4", metric.uniqueness_key
    end
  end

  test "correctly sets params" do
    freeze_time do
      request = create :mentor_request, id: 4

      metric = Metric::Create.(:request_mentoring, Time.current, request:)

      expected = { "request" => "gid://website/Mentor::Request/4" }
      assert_equal expected, metric.params
    end
  end

  test "uniqueness_key is unique per request" do
    uniqueness_keys = Array.new(10) do
      request = create :mentor_request
      Metric::Create.(:request_mentoring, Time.current, request:)
    end

    assert_equal uniqueness_keys.uniq.size, uniqueness_keys.size
  end

  test "idempotent" do
    request = create :mentor_request

    assert_idempotent_command do
      Metric::Create.(:request_mentoring, Time.utc(2012, 7, 25), request:)
    end
  end
end
