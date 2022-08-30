class Metrics::SignUpMetric < Metric
  def guard_params = user.id
end
