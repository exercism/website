require "test_helper"

class Metrics::SubmitSubmissionTest < ActiveSupport::TestCase
  test "create metric" do
    freeze_time do
      track = create :track, id: 2
      user = create :user, id: 3
      submission = create :submission, id: 4
      occurred_at = Time.current - 5.seconds
      request_context = { remote_ip: '127.0.0.1' }

      metric = Metric::Create.(:submit_submission, occurred_at, submission:, track:, user:, request_context:)

      assert_instance_of Metrics::SubmitSubmissionMetric, metric
      assert_equal occurred_at, metric.occurred_at
      assert_equal user, metric.user
      assert_equal track, metric.track
      assert_equal 'US', metric.country_code
      assert_equal "SubmitSubmissionMetric|4", metric.uniqueness_key
    end
  end

  test "correctly sets params" do
    freeze_time do
      submission = create :submission, id: 4

      metric = Metric::Create.(:submit_submission, Time.current, submission:)

      expected = { "submission" => "gid://website/Submission/4" }
      assert_equal expected, metric.params
    end
  end

  test "uniqueness_key is unique per submission" do
    uniqueness_keys = Array.new(10) do
      submission = create :submission
      Metric::Create.(:submit_submission, Time.current, submission:)
    end

    assert_equal uniqueness_keys.uniq.size, uniqueness_keys.size
  end

  test "idempotent" do
    submission = create :submission

    assert_idempotent_command do
      Metric::Create.(:submit_submission, Time.utc(2012, 7, 25), submission:)
    end
  end

  test "calls increment_num_solutions!" do
    submission = create :submission

    Metrics.expects(:increment_num_submissions!)

    Metric::Create.(:submit_submission, Time.utc(2012, 7, 25), submission:)
  end
end
