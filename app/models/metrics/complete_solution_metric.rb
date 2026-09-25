class Metrics::CompleteSolutionMetric < Metric
  params :solution

  delegate :exercise, to: :solution, allow_nil: true
  def guard_params = solution.id
end
