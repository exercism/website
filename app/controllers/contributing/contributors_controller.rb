module Contributing
  class ContributorsController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[index]

    def index
      response.set_header('Link', '<https://exercism.io/profiles>; rel="canonical"')

      # TODO: Set these correctly
      @featured_contributor = User.first
      @latest_contributor = User.second

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
      @contributors = SerializeContributors.(users, starting_rank: 1, contextual_data: contextual_data)
    end
  end
end
