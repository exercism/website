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

      # This is only the payload the ticker starts with: once the page is up,
      # useActivityTicker's MetricsChannel subscription replaces it with live
      # activity. So it is safe to cache despite the ticker feeling live, and it
      # is expensive enough to be worth caching.
      # The ORDER BY id cannot use index_metrics_on_type_and_track_id_and_occurred_at,
      # so the lookup filesorts, and to_broadcast_hash then walks the metric's
      # whole object graph (submission, solution, exercise, user, profile).
      def initial_data
        Rails.cache.fetch("track/#{track.id}/activity_ticker/initial_data", expires_in: 15.minutes) do
          Metric.where(track_id: track.id, type: ALLOWED_METRIC_TYPES).last&.to_broadcast_hash
        end
      rescue StandardError
        {}
      end

      ALLOWED_METRIC_TYPES = [
        'Metrics::PublishSolutionMetric',
        'Metrics::OpenPullRequestMetric',
        'Metrics::StartSolutionMetric',
        'Metrics::MergePullRequestMetric',
        'Metrics::SubmitSubmissionMetric',
        'Metrics::CompleteSolutionMetric'
      ].freeze
    end
  end
end
