class TracksController < ApplicationController
  before_action :use_track, except: :index

  allow_unauthenticated! :index, :show

  def authenticated_index
    # TODO: This should cease to be an instance variable
    # once the view is using the tracks_json to render
    @tracks = Track::Search.(
      criteria: params[:criteria],
      tags: params[:tags],
      status: params[:status],
      user: current_user
    )

    @tracks_json = SerializeTracks.(@tracks, current_user).to_json
  end

  def authenticated_show
    @user_track = current_user.user_tracks.find_by(track: @track)
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
