module ReactComponents
  module Track
    class ActivityTicker < ReactComponent
      initialize_with :track

      def to_s
        super("track-activity-ticker", {
          track_title: track.title,
          initial_data:
        })
      end

      def initial_data
        last_metric = Metric.where(track_id: track.id, type: ALLOWED_METRIC_TYPES).last
        last_metric.to_broadcast_hash
      end

      ALLOWED_METRIC_TYPES = [
        'Metrics::PublishSolutionMetric',
        'Metrics::OpenPullRequestMetric',
        'Metrics::MergePullRequestMetric'
      ].freeze
    end
  end
end
