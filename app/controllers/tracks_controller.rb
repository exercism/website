class TracksController < ApplicationController
  before_action :use_track, except: :index
  skip_before_action :authenticate_user!

  def index
    tracks = Track::Search.(
      criteria: params[:criteria],
      tags: params[:tags],
      status: params[:status],
      user: current_user
    )

    @tracks_data = SerializeTracks.(tracks, current_user)
  end

  def show
    @user_track = UserTrack.for(current_user, @track)
    if @user_track
      render "tracks/show/joined"
    else
      render "tracks/show/unjoined"
    end
  end

  def join
    UserTrack::Create.(current_user, @track)
    redirect_to action: :show
  end

  private
  def use_track
    @track = Track.find(params[:id])
  end
end
