class Metrics::JoinTrackMetric < Metric
  params :user_track

  def guard_params = user_track.id
end
