class Test::Components::Student::TrackListController < ApplicationController
  def show
    @data = API::TracksSerializer.new(Track.all, User.first)
  end

  def tracks
    return head :internal_server_error if params[:state] == "Loading"

    tracks = Track::Search.(
      criteria: params[:criteria],
      tags: params[:tags],
      status: params[:status],
      user: User.first
    )

    render json: API::TracksSerializer.new(tracks, User.first).to_hash
  end
end
