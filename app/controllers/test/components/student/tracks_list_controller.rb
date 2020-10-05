class Test::Components::Student::TracksListController < ApplicationController
  def show
    @data = SerializeTracks.(Track.all, User.first)
  end

  def tracks
    return head :internal_server_error if params[:state] == "Loading" || params[:state] == "Error"

    tags = params[:tags].to_s.split(",")

    tracks = Track::Search.(
      criteria: params[:criteria],
      tags: tags,
      status: params[:status],
      user: User.first
    )

    render json: SerializeTracks.(tracks, User.first)
  end
end
