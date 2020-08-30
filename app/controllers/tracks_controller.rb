class TracksController < ApplicationController
  before_action :use_track, except: :index

  def authenticated_index
    @tracks = Track.all
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
