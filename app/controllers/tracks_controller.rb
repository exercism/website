class TracksController < ApplicationController
  before_action :use_track, except: :index
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    tracks = Track::Search.(
      criteria: params[:criteria],
      tags: params[:tags],
      status: params[:status],
      user: current_user
    )

    @tracks_data = SerializeTracks.(tracks, current_user)
    @num_tracks = Track.count

    # TODO: Change this to only select the fields needed for an icon
    @track_icons = Track.order('rand()').limit(8).map(&:icon_name)
  end

  def show
    @user_track = UserTrack.for(current_user, @track)

    if @user_track
      @activities = UserTrack::RetrieveRecentlyActiveSolutions.(@user_track).map do |solution|
        SerializeSolutionActivity.(solution)
      end

      render "tracks/show/joined"
    else
      @showcase_exercises = @track.exercises.order("RAND()").limit(3).to_a
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
