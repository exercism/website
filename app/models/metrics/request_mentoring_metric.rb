class Metrics::RequestMentoringMetric < Metric
  params :request

  def guard_params = request.id
end
