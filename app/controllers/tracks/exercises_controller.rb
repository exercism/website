class Tracks::ExercisesController < ApplicationController
  before_action :use_track
  before_action :use_exercise, only: %i[show start edit complete tooltip]
  before_action :use_solution, only: %i[show edit complete tooltip]

  skip_before_action :authenticate_user!, only: %i[index show tooltip]
  skip_before_action :verify_authenticity_token, only: :start
  disable_site_header! only: [:edit]

  def index
    @num_completed = @user_track.num_completed_exercises
  end

  # TODO: There is lots of logic in this view
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

  # TODO: This should be an API method, not a HTML one.
  def start
    Solution::Create.(current_user, @exercise)

    respond_to do |format|
      format.html { redirect_to action: :edit }
      format.json do
        render json: {
          links: {
            exercise: Exercism::Routes.edit_track_exercise_path(@exercise.track, @exercise)
          }
        }
      end
    end
  end

  def edit; end

  # TODO: Delete when this is working via the API
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
