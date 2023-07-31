class Metrics::CompleteSolutionMetric < Metric
  params :solution

  def guard_params = solution.id
end
