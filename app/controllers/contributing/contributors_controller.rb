module Contributing
  class ContributorsController < ApplicationController
    def index
      response.set_header('Link', '<https://exercism.io/profiles>; rel="canonical"')

      @featured_contributor = User.first
      @latest_contributor = User.second

      users = User.first(10)
      contextual_data = User::ReputationToken::CalculateContextualData.([1530], period: params[:period])
      @contributors = SerializeContributors.(users, starting_rank: 1, contextual_data: contextual_data)
    end
  end
end
