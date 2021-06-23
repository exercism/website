require "test_helper"

class MarkOutdatedReputationPeriodsJobTest < ActiveJob::TestCase
  test "year" do
    travel_to(Date.new(2021, 6, 30)) do
      User::ReputationPeriod::MarkOutdated.expects(:call).with(
        earned_on: Date.new(2020, 6, 30), period: :year
      )

      MarkOutdatedReputationPeriodsJob.perform_now('year')
    end
  end

  test "month" do
    travel_to(Date.new(2021, 6, 30)) do
      User::ReputationPeriod::MarkOutdated.expects(:call).with(
        earned_on: Date.new(2021, 5, 31), period: :month
      )

      MarkOutdatedReputationPeriodsJob.perform_now('month')
    end
  end

  test "week" do
    travel_to(Date.new(2021, 6, 30)) do
      User::ReputationPeriod::MarkOutdated.expects(:call).with(
        earned_on: Date.new(2021, 6, 23), period: :week
      )

      MarkOutdatedReputationPeriodsJob.perform_now('week')
    end
  end
end
