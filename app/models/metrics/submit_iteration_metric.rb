class Metrics::SubmitIterationMetric < Metric
  params :iteration

  delegate :exercise, to: :iteration

  def guard_params = iteration.id
end
