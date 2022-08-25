class Metrics::MergePullRequestMetric < Metric
  params :pull_request

  def guard_params = pull_request.id
  def user_public? = true

  # Don't use the request's remote IP as that will always be GitHub's IP address
  def store_country_code? = false
end
