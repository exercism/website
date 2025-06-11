class API::CommunitySolutionsController < API::BaseController
  skip_before_action :authenticate_user!
  before_action :authenticate_user
  before_action :use_exercise

  def index
    render json: AssembleExerciseCommunitySolutionsList.(@exercise, search_params)
  end

  private
  def use_exercise
    @track = Track.cached.find_by!(slug: params[:track_slug])
    @exercise = @track.exercises.find(params[:exercise_slug])
  end

  def search_params
    params.permit(AssembleExerciseCommunitySolutionsList.permitted_params)
  end
end
