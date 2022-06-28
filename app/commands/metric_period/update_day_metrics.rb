class MetricPeriod::UpdateDayMetrics
  include Mandate

  def initialize(day_to_update = Time.current.prev_day)
    @day_to_update = day_to_update.beginning_of_day
  end

  def call
    # TODO: add nil track

    metric_actions.product(Track.all).each do |metric_action, track|
      count = metric_count(metric_action, track)

      MetricPeriod::Day.find_create_or_find_by!(metric_action:, track:, day: day_to_update.day) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end

  private
  attr_reader :day_to_update

  def metric_actions = MetricPeriod::Day.metric_actions.keys.map(&:to_sym)
  def metric_count(metric_action, track) = metrics[[metric_action, track.id]].to_a.size

  memoize
  def metrics
    Metric.
      where('created_at >= ? AND created_at < ?', day_to_update, day_to_update.next_day).
      group_by { |m| [m.metric_action, m.track_id] }
  end
end
