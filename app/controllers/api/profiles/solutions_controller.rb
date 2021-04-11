module API
  class Profiles::SolutionsController < BaseController
    before_action :use_user

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

    private
    def use_user
      @user = User.find_by!(handle: params[:profile_id])

      # TOOD: Handle and test this properly
      raise unless @user.profile
    end
  end
end
