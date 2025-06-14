module Contributing
  class ContributorsController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[index]
    before_action :cache_public_action!, only: %i[index]

    def index
      response.set_header('Link', '<https://exercism.org/profiles>; rel="canonical"')

      nil unless stale?(etag: Time.now.to_i / 300 * 300)

      # TODO: (Required) Set these correctly
      # @featured_contributor = User.first
      # @latest_contributor = User.second
    end
  end
end
