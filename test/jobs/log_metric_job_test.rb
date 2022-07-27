require "test_helper"

class LogMetricJobTest < ActiveJob::TestCase
  test "creates metric" do
    freeze_time do
      type = :submit_solution
      solution = create :concept_solution
      occurred_at = Time.current - 3.seconds
      track = solution.track
      user = solution.user

      LogMetricJob.perform_now(type, occurred_at, track:, user:, solution:)

      metric = Metric.last
      assert_equal Metrics::SubmitSolutionMetric, metric.class
      assert_equal occurred_at, metric.occurred_at
      assert_equal 'US', metric.country_code
      assert_equal Time.current, metric.created_at
      assert_equal Time.current, metric.updated_at
      assert_equal track, metric.track
      assert_equal user, metric.user
    end
  end
end
