class Metrics::PublishSolutionMetric < Metric
  params :solution

  delegate :exercise, to: :solution

  def guard_params = solution.id
  def user_public? = true
end
