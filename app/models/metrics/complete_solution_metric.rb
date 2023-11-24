class Metrics::CompleteSolutionMetric < Metric
  params :solution

  delegate :exercise, to: :solution
  def guard_params = solution.id
end
