class Metrics::StartSolutionMetric < Metric
  params :solution

  def guard_params = solution.id
end
