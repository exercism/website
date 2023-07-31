class Metrics::RequestPrivateMentoringMetric < Metric
  params :request

  def guard_params = request.id
end
