class Metrics::SubmitSubmissionMetric < Metric
  params :submission

  delegate :exercise, to: :submission

  def guard_params = submission.id
end
