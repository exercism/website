class Community::VideosController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @live_event = StreamingEvent.live.first
    @featured_event = StreamingEvent.next_featured unless @live_event
    @scheduled_events = StreamingEvent.next_5
  end
end
