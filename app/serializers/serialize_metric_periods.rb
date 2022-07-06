class SerializeMetricPeriods
  include Mandate

  initialize_with :metric_periods

  def call
    metric_periods.includes(:track).map do |metric_period|
      serialize_metric_period(metric_period)
    end
  end

  private
  def serialize_metric_period(metric_period)
    key = metric_period.class.name.demodulize.underscore
    value = metric_period.send(key)

    {
      count: metric_period.count,
      track_slug: metric_period.track&.slug,
      type: metric_period.metric_type.demodulize.underscore
    }.merge(key => value)
  end
end
