class Tracks::IterationsController < ApplicationController
  before_action :use_solution

  def index
    @iterations = @solution.iterations.order(id: :desc)
  end

  private
  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
  end
end
