class Metrics::PublishSolutionMetric < Metric
  params :solution

  def guard_params = solution.id
end
