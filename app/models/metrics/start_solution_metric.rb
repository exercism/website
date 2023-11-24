class Metrics::StartSolutionMetric < Metric
  params :solution

  delegate :exercise, to: :solution
  def guard_params = solution.id

  after_create do
    Metrics.increment_num_solutions!
  end
end
