class Metrics::SignUpMetric < Metric
  def guard_params = user.id

  after_create do
    Metrics.increment_num_users!
  end
end
