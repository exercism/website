module Contributing
  class ContributorsController < ApplicationController
    def index
      response.set_header('Link', '<https://exercism.io/profiles>; rel="canonical"')

      @featured_contributor = User.first
      @latest_contributor = User.second

      users = User.first(10)
      contextual_data = User::ReputationToken::CalculateContextualData.(users.map(&:id))
      @contributors = SerializeContributors.(users, starting_rank: 1, contextual_data: contextual_data)
    end
  end
end
