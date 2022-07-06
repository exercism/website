class Metrics::MergePullRequestMetric < Metric
  params :pull_request

  def guard_params = pull_request.id
end
