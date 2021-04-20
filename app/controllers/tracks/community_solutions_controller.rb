class Tracks::CommunitySolutionsController < ApplicationController
  before_action :use_track
  before_action :use_exercise

  skip_before_action :authenticate_user!

  def index
    @solutions = Solution::SearchCommunitySolutions.(@exercise)
    @endpoint = Exercism::Routes.api_track_exercise_community_solutions_url(@track, @exercise)
    @unscoped_total = @exercise.solutions.published.count
  end

  private
  def use_track
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track, external_if_missing: true)
  end

  def use_exercise
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
  end
end
