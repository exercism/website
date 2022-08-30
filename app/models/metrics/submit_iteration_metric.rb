class Metrics::SubmitIterationMetric < Metric
  params :iteration

  def guard_params = iteration.id
end
