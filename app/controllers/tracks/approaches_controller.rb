class Tracks::ApproachesController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution

  skip_before_action :authenticate_user!

  def index
    @videos = CommunityVideo.approved.for_exercise(@exercise)
    @introduction_html = Markdown::Parse.(@exercise.approaches_introduction)
  end

  def show; end

  def tooltip_locked = render_template_as_json

  private
  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
  end
end
