class MetricPeriod::UpdateMinuteMetrics
  include Mandate

  def initialize(minute_of_day_to_update = Time.current.prev_min)
    @minute_of_day_to_update = minute_of_day_to_update.beginning_of_minute
  end

  def call
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      generate_data!
    end
  end

  def generate_data!
    metric_types.product(track_ids).each do |metric_type, track_id|
      count = metric_counts[[metric_type, track_id]].to_i

      MetricPeriod::Minute.find_create_or_find_by!(metric_type:, track_id:, minute:) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end

  private
  attr_reader :minute_of_day_to_update

  def minute = minute_of_day_to_update.min_of_day
  def track_ids = Track.pluck(:id).push(nil)
  def metric_types = Metric.subclasses.map(&:name)

  memoize
  def metric_counts
    Metric.
      where('occurred_at >= ? AND occurred_at < ?', minute_of_day_to_update, minute_of_day_to_update.next_min).
      group(:type, :track_id).
      count
  end
end
