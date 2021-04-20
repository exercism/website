module API::Profiles
  class SolutionsController < BaseController
    def index
      solutions = Solution::SearchUserSolutions.(
        @user,
        status: :published,
        criteria: params[:criteria],
        track_slug: params[:track_slug],
        order: params[:order],
        page: params[:page]
      )

      render json: SerializePaginatedCollection.(
        solutions,
        serializer: SerializeCommunitySolutions
      )
    end
  end
end
