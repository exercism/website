class Metrics::PublishSolutionMetric < Metric
  params :solution

  def guard_params = solution.id
  def user_public? = true
end
