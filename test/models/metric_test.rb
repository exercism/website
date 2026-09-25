require "test_helper"

class MetricTest < ActiveSupport::TestCase
  test "retrieve_param returns nil when the record has been deleted" do
    metric = create :start_solution_metric
    metric.solution.delete

    assert_nil Metric.find(metric.id).solution
  end

  test "to_broadcast_hash includes the solution and its exercise" do
    solution = create :practice_solution, :published
    metric = create :publish_solution_metric, params: { solution: }

    hash = Metric.find(metric.id).to_broadcast_hash

    assert_equal solution.exercise.title, hash[:exercise][:title]
    assert_equal Exercism::Routes.published_solution_url(solution), hash[:published_solution_url]
  end

  test "to_broadcast_hash skips the solution and exercise when the solution has been deleted" do
    metric = create :start_solution_metric
    metric.solution.delete

    hash = Metric.find(metric.id).to_broadcast_hash

    assert_equal metric.id, hash[:id]
    assert_equal "start_solution_metric", hash[:type]
    refute hash.key?(:exercise)
    refute hash.key?(:published_solution_url)
  end

  test "to_broadcast_hash skips the pull request when it has been deleted" do
    metric = create :open_pull_request_metric
    metric.pull_request.delete

    hash = Metric.find(metric.id).to_broadcast_hash

    assert_equal metric.id, hash[:id]
    refute hash.key?(:pull_request)
  end
end
