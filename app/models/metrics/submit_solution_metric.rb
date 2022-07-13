class Metrics::SubmitSolutionMetric < Metric
  params :solution

  def guard_params = solution.id
end
