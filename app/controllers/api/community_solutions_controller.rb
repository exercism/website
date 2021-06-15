module API
  class CommunitySolutionsController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user
    before_action :use_exercise

    def index
      render json: AssembleExerciseCommunitySolutionsList.(@exercise, search_params)
    end

    private
    def use_exercise
      @track = Track.find(params[:track_id])
      @exercise = @track.exercises.find(params[:exercise_id])
    end

    def search_params
      params.permit(AssembleExerciseCommunitySolutionsList.keys)
    end
  end
end
