class Tracks::ExercisesController < ApplicationController
  before_action :use_track
  before_action :use_exercise, only: %i[show start complete]
  before_action :use_solution, only: %i[show complete]

  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @exercises = @track.exercises
    @num_completed = @user_track.num_completed_exercises
  end

  # TODO: There is lots of logic in this view
  # that should be extracted into a view model
  # to allow for pre-caching of solution data
  def show
    @iteration = @solution.iterations.last if @solution
  end

  def start
    solution = Solution::Create.(current_user, @exercise)
    redirect_to edit_solution_path(solution.uuid)
  end

  def complete
    Solution::Complete.(@solution, @user_track)
    redirect_to action: :show
  end

  private
  def use_track
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track, external_if_missing: true)
  end

  def use_exercise
    @exercise = @track.exercises.find(params[:id])
  end

  def use_solution
    @solution = Solution.for(current_user, @exercise)
  end
end
