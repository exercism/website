require "test_helper"

class Metrics::CompleteSolutionTest < ActiveSupport::TestCase
  test "create metric" do
    freeze_time do
      track = create :track, id: 2
      user = create :user, id: 3
      solution = create :concept_solution, id: 4
      occurred_at = Time.current - 5.seconds

      metric = Metric::Create.(:complete_solution, occurred_at, solution:, track:, user:)

      assert_equal Metrics::CompleteSolutionMetric, metric.class
      assert_equal occurred_at, metric.occurred_at
      assert_equal user, metric.user
      assert_equal track, metric.track
      assert_equal "CompleteSolutionMetric|4", metric.uniqueness_key
    end
  end

  test "correctly sets params" do
    freeze_time do
      solution = create :concept_solution, id: 4

      metric = Metric::Create.(:complete_solution, Time.current, solution:)

      expected = { "solution" => "gid://website/ConceptSolution/4" }
      assert_equal expected, metric.params
    end
  end

  test "uniqueness_key is unique per solution" do
    uniqueness_keys = Array.new(10) do
      solution = create :concept_solution
      Metric::Create.(:complete_solution, Time.current, solution:)
    end

    assert_equal uniqueness_keys.uniq.size, uniqueness_keys.size
  end

  test "idempotent" do
    solution = create :concept_solution

    assert_idempotent_command do
      Metric::Create.(:complete_solution, Time.utc(2012, 7, 25), solution:)
    end
  end
end
