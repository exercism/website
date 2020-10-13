class Test::Components::Student::TracksListController < ApplicationController
  def show
    @user = User.first
    @data = SerializeTracks.(Track.all, @user)
  end

  def tracks
    return head :internal_server_error if params[:state] == "Loading" || params[:state] == "Error"

    tracks = Track::Search.(
      criteria: params[:criteria],
      tags: params[:tags],
      status: params[:status],
      user: User.first
    )

    render json: SerializeTracks.(tracks, User.first)
  end
end
