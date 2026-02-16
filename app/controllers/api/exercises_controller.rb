class API::ExercisesController < API::BaseController
  skip_before_action :authenticate_user!
  before_action :authenticate_user
  before_action :use_track
  before_action :use_exercise, only: [:start]

  def index
    render json: AssembleExerciseList.(current_user, @track, params)
  end

  def start
    Solution::Create.(current_user, @exercise)

    render json: {
      links: {
        exercise: Exercism::Routes.edit_track_exercise_url(@track, @exercise)
      }
    }
  rescue UserTrackNotFoundError
    render_403(:track_not_joined)
  rescue ExerciseLockedError
    render_403(:exercise_locked)
  end

  private
  def use_track
    @track = Track.find(params[:track_slug])
  end

  def use_exercise
    @exercise = @track.exercises.find(params[:slug])
  end
end
