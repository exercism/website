class Metrics::StartSolutionMetric < Metric
  params :solution

  def guard_params = solution.id

  after_create do
    Metrics.increment_num_solutions!
  end
end
