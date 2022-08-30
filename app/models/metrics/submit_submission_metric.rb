class Metrics::SubmitSubmissionMetric < Metric
  params :submission

  def guard_params = submission.id
end
