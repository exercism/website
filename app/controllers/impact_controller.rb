class ImpactController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @track = Track.find(params[:track_slug]) if params[:track_slug].present?
    @last_24_hours = last_24_hours
    @last_month = last_month
  end

  private
  METRICS = {
    num_solutions_submitted: Metrics::StartSolutionMetric.name,
    num_solutions_completed: Metrics::CompleteSolutionMetric.name,
    num_opened_pull_requests: Metrics::OpenPullRequestMetric.name
  }.freeze
  def last_24_hours
    METRICS.transform_values { |v| count_last_24_hours(v) }
  end

  def last_month
    METRICS.transform_values { |v| count_last_month(v) }
  end

  def count_last_24_hours(metric_type)
    query = MetricPeriod::Minute.where(metric_type:)
    query = query.where(track_id: @track.id) if @track
    query.sum(:count)
  end

  def count_last_month(metric_type)
    query = MetricPeriod::Day.where(metric_type:)
    query = query.where(track_id: @track.id) if @track
    query.sum(:count)
  end
end
