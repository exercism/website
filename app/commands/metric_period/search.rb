class MetricPeriod::Search
  include Mandate

  PERIOD_TYPES = %i[month day minute].freeze
  METRIC_TYPES = %i[
    open_issue_metric open_pull_request_metric merge_pull_request_metric
    start_solution_metric complete_solution_metric publish_solution_metric
    request_mentoring_metric request_private_mentoring_metric finish_mentoring_metric
    join_track_metric
  ].freeze

  initialize_with :period_type, :options

  def call
    raise InvalidMetricPeriodError unless PERIOD_TYPES.include?(period_type.to_sym)

    @metric_periods = "metric_period/#{period_type}".camelize.constantize.all
    filter_track!
    filter_period_begin!
    filter_period_end!
    filter_metric_type!
    @metric_periods
  end

  private
  attr_reader :metric_periods

  def filter_track!
    return if options[:track_slug].blank?

    @metric_periods = @metric_periods.where(track: Track.find_by(slug: options[:track_slug]))
  end

  def filter_period_begin!
    return if options[:period_begin].blank?

    @metric_periods = @metric_periods.where("#{period_type} >= ?", options[:period_begin].to_i)
  end

  def filter_period_end!
    return if options[:period_end].blank?

    @metric_periods = @metric_periods.where("#{period_type} <= ?", options[:period_end].to_i)
  end

  def filter_metric_type!
    return if options[:metric_type].blank?

    raise InvalidMetricTypeError unless METRIC_TYPES.include?(options[:metric_type].to_sym)

    metric_type = "metrics/#{options[:metric_type]}".camelize.constantize
    @metric_periods = @metric_periods.where(metric_type:)
  end
end
