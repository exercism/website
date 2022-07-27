class Metrics::OpenPullRequestMetric < Metric
  params :pull_request

  def guard_params = pull_request.id

  # Don't use the request's remote IP as that will always be GitHub's IP address
  def remote_ip = nil
end
