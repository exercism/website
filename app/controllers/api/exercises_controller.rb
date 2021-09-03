module API
  class ExercisesController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user
    before_action :use_track

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
    end

    private
    def use_track
      @track = Track.find(params[:track_slug])
    end
  end
end
