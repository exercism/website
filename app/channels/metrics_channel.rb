class MetricsChannel < ApplicationCable::Channel
  def self.broadcast!(metric)
    ActionCable.server.broadcast(
      'metrics',
      {
        metric: metric.to_broadcast_hash
      }
    )
  end

  def subscribed
    stream_from "metrics"
  end

  def unsubscribed; end
end
