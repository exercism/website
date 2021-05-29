class MarkOutdatedReputationPeriodsJob < ApplicationJob
  queue_as :reputation

  def perform(period)
    User::ReputationPeriod::MarkOutdated.(earned_on: Date.current, period: period.to_sym)
  end
end
