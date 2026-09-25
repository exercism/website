class Metrics::SubmitIterationMetric < Metric
  params :iteration

  delegate :exercise, to: :iteration, allow_nil: true

  def guard_params = iteration.id
end
