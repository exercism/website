class Metrics::OpenIssueMetric < Metric
  params :issue

  def guard_params = issue.id
end
