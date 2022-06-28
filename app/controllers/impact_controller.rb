class ImpactController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @track = Track.find(params[:track_slug]) if params[:track_slug].present?
    @last_24_hours = last_24_hours
    @last_month = last_month
  end

  private
  METRICS = {
    num_solutions_submitted: :submit_solution,
    num_solutions_completed: :complete_solution,
    num_opened_pull_requests: :open_pull_request
  }.freeze
  def last_24_hours
    METRICS.transform_values { |v| count_last_24_hours(v) }
  end

  def last_month
    METRICS.transform_values { |v| count_last_month(v) }
  end

  def count_last_24_hours(metric_action)
    query = MetricPeriod::Minute.where(metric_action:)
    query = query.where(track_id: @track.id) if @track
    query.sum(:count)
  end

  def count_last_month(metric_action)
    query = MetricPeriod::Day.where(metric_action:)
    query = query.where(track_id: @track.id) if @track
    query.sum(:count)
  end
end
