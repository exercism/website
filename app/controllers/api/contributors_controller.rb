module API
  class ContributorsController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user

    def index
      track_id = Track.find(params[:track]).id if params[:track].present?
      users = User::ReputationPeriod::Search.(
        period: params[:period],
        category: params[:category],
        track_id: track_id,
        user_handle: params[:user_handle],
        page: params[:page]
      )
      contextual_data = User::ReputationToken::CalculateContextualData.(
        users.map(&:id),
        period: params[:period],
        category: params[:category],
        track_id: track_id
      )

      render json: SerializePaginatedCollection.(
        users,
        serializer: SerializeContributors,
        serializer_kwargs: {
          starting_rank: (users.limit_value * (users.current_page - 1)) + 1,
          contextual_data: contextual_data
        }
      )
    end
  end
end
