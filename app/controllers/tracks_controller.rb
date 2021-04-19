class TracksController < ApplicationController
  before_action :use_track, except: :index
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @tracks = Track::Search.(
      criteria: params[:criteria],
      tags: params[:tags],
      status: params[:status],
      user: current_user
    )

    @num_tracks = Track.count

    # TODO: Change this to only select the fields needed for an icon
    @track_icon_urls = Track.active.order('rand()').limit(8).map(&:icon_url)
  end

  def show
    @user_track = UserTrack.for(current_user, @track)

    if @user_track
      @sample_completed_exercises = @user_track.sample_completed_exercises(5)

      if @track.course?
        @sample_learnt_concepts = @user_track.learnt_concepts.order("RAND()").limit(5)
        @sample_mastered_concepts = @user_track.mastered_concepts.order("RAND()").limit(5)
      else
        @sample_in_progress_exercises = @user_track.sample_in_progress_exercises(5)
        @sample_available_exercises = @user_track.sample_available_exercises(5)
      end

      @recent_solutions = UserTrack::RetrieveRecentlyActiveSolutions.(@user_track)

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
