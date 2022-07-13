class Metrics::FinishMentoringMetric < Metric
  params :discussion

  def guard_params = discussion.id
end
