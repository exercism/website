class MetricPeriod::UpdateDayMetrics
  include Mandate

  def initialize(day_to_update = Time.current.prev_day)
    @day_to_update = day_to_update.beginning_of_day
  end

  def call
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      generate_data!
    end
  end

  def generate_data!
    metric_types.product(track_ids).each do |metric_type, track_id|
      count = metric_count(metric_type, track_id)

      MetricPeriod::Day.find_create_or_find_by!(metric_type:, track_id:, day:) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end

  private
  attr_reader :day_to_update

  def day = day_to_update.day
  def track_ids = Track.pluck(:id).push(nil)
  def metric_types = Metric.subclasses.map(&:name)
  def metric_count(metric_type, track_id) = metrics[[metric_type, track_id]].to_a.size

  memoize
  def metrics
    Metric.
      where('occurred_at >= ? AND occurred_at < ?', day_to_update, day_to_update.next_day).
      group_by { |m| [m.type, m.track_id] }
  end
end
