class MetricPeriod::UpdateMinuteMetrics
  include Mandate

  def initialize(minute_of_day_to_update = Time.current.prev_min)
    @minute_of_day_to_update = minute_of_day_to_update.beginning_of_minute
  end

  def call
    metric_actions.product(Track.all).each do |metric_action, track|
      count = metric_count(metric_action, track)

      MetricPeriod::Minute.create_or_find_by!(metric_action:, track:, minute: minute_of_day_to_update.min_of_day) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end

  private
  attr_reader :minute_of_day_to_update

  def metric_actions = MetricPeriod::Minute.metric_actions.keys.map(&:to_sym)
  def metric_count(metric_action, track) = metrics[[metric_action, track.id]].to_a.size

  memoize
  def metrics
    Metric.
      where('created_at >= ? AND created_at < ?', minute_of_day_to_update, minute_of_day_to_update.next_min).
      group_by { |m| [m.metric_action, m.track_id] }
  end
end
