module API
  class CommunitySolutionsController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user
    before_action :use_exercise

    def index
      solutions = Solution::SearchCommunitySolutions.(
        @exercise,
        criteria: params[:criteria],
        page: params[:page]
      )

      render json: SerializePaginatedCollection.(
        solutions,
        serializer: SerializeCommunitySolutions,
        meta: {
          unscoped_total: @exercise.solutions.published.count
        }
      )
    end

    private
    def use_exercise
      @track = Track.find(params[:track_id])
      @exercise = @track.exercises.find(params[:exercise_id])
    end
  end
end
