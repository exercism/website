class StatsChannel < ApplicationCable::Channel
  def self.broadcast_increment!(metric)
    ActionCable.server.broadcast('stats', { metric: })
  end

  def subscribed
    stream_from "stats"
  end

  def unsubscribed; end
end
