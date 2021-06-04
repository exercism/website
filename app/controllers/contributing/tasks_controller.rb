module Contributing
  class TasksController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[index]

    def index
      @tasks = [
        {
          title: "Write Boolean concept exercise for Python track",
          isNew: true,
          track: {
            title: Track.first.title,
            icon_url: Track.first.icon_url
          },
          links: {
            github_url: "#"
          }
        }
      ]
    end
  end
end
