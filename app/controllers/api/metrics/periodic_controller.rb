class API::Metrics::PeriodicController < API::BaseController
  def index
    period_type = index_params[:period_type]
    raise MissingMetricPeriodError if period_type.blank?

    options = index_params.except(:period_type)

    metric_periods = MetricPeriod::Search.(period_type, options)
    render json: { data: SerializeMetricPeriods.(metric_periods) }
  rescue MissingMetricPeriodError
    render_400(:missing_metric_period, valid_metric_periods: MetricPeriod::Search::PERIOD_TYPES)
  rescue InvalidMetricPeriodError
    render_400(:invalid_metric_period, valid_metric_periods: MetricPeriod::Search::PERIOD_TYPES)
  rescue InvalidMetricTypeError
    render_400(:invalid_metric_type, valid_metric_types: MetricPeriod::Search::METRIC_TYPES)
  end

  private
  def index_params = params.permit(:period_type, :metric_type, :period_begin, :period_end, :track_slug)
end
