class Metrics::OpenIssueMetric < Metric
  params :issue

  def guard_params = issue.id
  def user_public? = true

  # Don't use the request's remote IP as that will always be GitHub's IP address
  def store_country_code? = false
end
