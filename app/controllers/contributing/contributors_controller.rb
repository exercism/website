module Contributing
  class ContributorsController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[index]

    def index
      response.set_header('Link', '<https://exercism.org/profiles>; rel="canonical"')

      # TODO: (Required) Set these correctly
      # @featured_contributor = User.first
      # @latest_contributor = User.second
    end
  end
end
