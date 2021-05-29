class SweepReputationPeriodsJob < ApplicationJob
  queue_as :reputation

  def perform
    User::ReputationPeriod::Sweep.()
  end
end
