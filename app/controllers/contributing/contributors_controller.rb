module Contributing
  class ContributorsController < ApplicationController
    def index
      response.set_header('Link', '<https://exercism.io/profiles>; rel="canonical"')

      @featured_contributor = User.first
      @latest_contributor = User.second
      @contributors = SerializeContributors.(User.first(10), 1)
    end
  end
end
