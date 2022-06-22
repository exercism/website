class ImpactController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @last_24_hours = last_24_hours
    @last_month = last_month
  end

  private
  def last_24_hours
    {
      num_solutions_submitted: count_last_24_hours(:submit_solution),
      num_opened_pull_requests: count_last_24_hours(:open_pull_request)
    }
  end

  def count_last_24_hours(metric_action) = MetricPeriod::Minute.where(metric_action:).sum(:count)

  def last_month
    {
      num_solutions_submitted: count_last_month(:submit_solution),
      num_opened_pull_requests: count_last_month(:open_pull_request)
    }
  end

  def count_last_month(metric_action) = MetricPeriod::Day.where(metric_action:).sum(:count)
end
