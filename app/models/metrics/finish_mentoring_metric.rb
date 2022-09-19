class Metrics::FinishMentoringMetric < Metric
  params :discussion

  def guard_params = discussion.id

  after_create do
    Metrics.increment_num_discussions!
  end
end
