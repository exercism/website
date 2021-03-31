module API
  class CommunitySolutionsController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user
    before_action :use_exercise

    def index
      solutions = Solution::SearchCommunitySolutions.(
        @exercise,
        page: params[:page]
      )
      output = {
        solutions: SerializePaginatedCollection.(
          solutions,
          serializer: SerializeCommunitySolutions
        )
      }

      render json: output
    end

    private
    def use_exercise
      @track = Track.find(params[:track_id])
      @exercise = @track.exercises.find(params[:exercise_id])
    end
  end
end
