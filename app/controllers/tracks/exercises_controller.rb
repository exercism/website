class Tracks::ExercisesController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_track!
  before_action :use_exercise!, only: %i[show start edit complete tooltip no_test_runner]
  before_action :use_solution, only: %i[show edit complete tooltip]

  skip_before_action :authenticate_user!, only: %i[index show tooltip]
  skip_before_action :verify_authenticity_token, only: :start

  def index
    @num_completed = @user_track.num_completed_exercises
  end

  # TODO: (Optional) There is lots of logic in this view
  # that should be extracted into a view model
  # to allow for pre-caching of solution data
  def show
    @iteration = @solution.iterations.last if @solution
  end

  def tooltip
    render json: {
      exercise: SerializeExercise.(@exercise, user_track: @user_track),
      solution: (@solution ? SerializeSolution.(@solution, user_track: @user_track) : nil),
      track: SerializeTrack.(@exercise.track, @user_track)
    }
  end

  def edit
    return redirect_to(action: :show) if @user_track.external?
    return redirect_to(action: :no_test_runner) unless @exercise.has_test_runner?

    @solution ||= Solution::Create.(current_user, @exercise)
  rescue ExerciseLockedError
    redirect_to action: :show
  end

  def no_test_runner
    redirect_to(action: :edit) if @exercise.has_test_runner?
  end

  private
  def use_exercise!
    @exercise = @track.exercises.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
