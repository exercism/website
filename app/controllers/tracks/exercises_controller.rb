class Tracks::ExercisesController < ApplicationController
  before_action :use_track
  before_action :use_exercise, only: %i[show start complete]
  before_action :use_solution, only: %i[show complete]

  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @exercises = @track.exercises
  end

  def show; end

  def start
    solution = Solution::Create.(current_user, @exercise)
    redirect_to edit_solution_path(solution.uuid)
  end

  def complete
    ConceptExercise::Complete.(current_user, @exercise)
    redirect_to action: :show
  end

  private
  def use_track
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)
  end

  def use_exercise
    @exercise = @track.exercises.find(params[:id])
  end

  def use_solution
    @solution = Solution.for(current_user, @exercise)
  end
end
