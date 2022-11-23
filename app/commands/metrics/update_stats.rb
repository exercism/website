class Metrics::UpdateStats
  include Mandate

  def call
    Metrics.set_num_users!
    Metrics.set_num_solutions!
    Metrics.set_num_discussions!
  end
end
