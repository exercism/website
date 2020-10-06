class TracksController < ApplicationController
  before_action :use_track, except: :index

  allow_unauthenticated! :index, :show

  def authenticated_index
    tracks = Track::Search.(
      criteria: params[:criteria],
      tags: params[:tags],
      status: params[:status],
      user: current_user
    )

    @tracks_data = SerializeTracks.(tracks, current_user)
  end

  def authenticated_show
    @user_track = UserTrack.for(current_user, @track)
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
