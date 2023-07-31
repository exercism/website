class MarkOutdatedReputationPeriodsJob < ApplicationJob
  queue_as :reputation

  def perform(period)
    case period.to_sym
    when :year
      earned_on = Date.current - 365.days
    when :month
      earned_on = Date.current - 30.days
    when :week
      earned_on = Date.current - 7.days
    else
      raise "Unexpected period: #{period}"
    end

    User::ReputationPeriod::MarkOutdated.(earned_on:, period: period.to_sym)
  end
end
