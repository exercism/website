require "test_helper"

class Metrics::StartSolutionTest < ActiveSupport::TestCase
  test "create metric" do
    freeze_time do
      track = create :track, id: 2
      user = create :user, id: 3
      solution = create :concept_solution, id: 4
      occurred_at = Time.current - 5.seconds
      request_context = { remote_ip: '127.0.0.1' }

      metric = Metric::Create.(:start_solution, occurred_at, solution:, track:, user:, request_context:)

      assert_instance_of Metrics::StartSolutionMetric, metric
      assert_equal occurred_at, metric.occurred_at
      assert_equal user, metric.user
      assert_equal track, metric.track
      assert_equal 'US', metric.country_code
      assert_equal "StartSolutionMetric|4", metric.uniqueness_key
    end
  end

  test "correctly sets params" do
    freeze_time do
      solution = create :concept_solution, id: 4

      metric = Metric::Create.(:start_solution, Time.current, solution:)

      expected = { "solution" => "gid://website/ConceptSolution/4" }
      assert_equal expected, metric.params
    end
  end

  test "uniqueness_key is unique per solution" do
    uniqueness_keys = Array.new(10) do
      solution = create :concept_solution
      Metric::Create.(:start_solution, Time.current, solution:)
    end

    assert_equal uniqueness_keys.uniq.size, uniqueness_keys.size
  end

  test "idempotent" do
    solution = create :concept_solution

    assert_idempotent_command do
      Metric::Create.(:start_solution, Time.utc(2012, 7, 25), solution:)
    end
  end

  test "calls increment_num_solutions!" do
    solution = create :concept_solution

    Metrics.expects(:increment_num_solutions!)

    Metric::Create.(:start_solution, Time.utc(2012, 7, 25), solution:)
  end
end
