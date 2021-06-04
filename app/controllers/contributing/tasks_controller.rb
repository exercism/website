module Contributing
  class TasksController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[index]

    def index
      @data = AssembleTasks.(params)

      # @data = {
      #   results: [
      #     {
      #       title: "Write Boolean concept exercise for Python track",
      #       isNew: true,
      #       track: {
      #         title: Track.first.title,
      #         icon_url: Track.first.icon_url
      #       },
      #       tags: {
      #         action: :create,
      #         type: :docs,
      #         size: :small,
      #         knowledge: :elementary,
      #         module: :analyzer
      #       },
      #       links: {
      #         github_url: "#"
      #       }
      #     },
      #     {
      #       title: "Write Boolean concept exercise for Python track",
      #       isNew: true,
      #       track: {
      #         title: Track.first.title,
      #         icon_url: Track.first.icon_url
      #       },
      #       tags: {
      #         action: :improve,
      #         type: :coding,
      #         size: :tiny,
      #         knowledge: :advanced,
      #         module: :"practice-exercise"
      #       },
      #       links: {
      #         github_url: "#"
      #       }
      #     },
      #     {
      #       title: "Write Boolean concept exercise for Python track",
      #       isNew: true,
      #       track: {
      #         title: Track.first.title,
      #         icon_url: Track.first.icon_url
      #       },
      #       tags: {
      #         action: :fix,
      #         type: :docker,
      #         size: :medium,
      #         knowledge: :intermediate,
      #         module: :"concept-exercise"
      #       },
      #       links: {
      #         github_url: "#"
      #       }
      #     },
      #     {
      #       title: "Write Boolean concept exercise for Python track",
      #       isNew: true,
      #       track: {
      #         title: Track.first.title,
      #         icon_url: Track.first.icon_url
      #       },
      #       tags: {
      #         action: :sync,
      #         type: :ci,
      #         size: :large,
      #         knowledge: :advanced,
      #         module: :"test-runner"
      #       },
      #       links: {
      #         github_url: "#"
      #       }
      #     },
      #     {
      #       title: "Write Boolean concept exercise for Python track",
      #       isNew: true,
      #       track: {
      #         title: Track.first.title,
      #         icon_url: Track.first.icon_url
      #       },
      #       tags: {
      #         action: :proofread,
      #         type: :content,
      #         size: :massive,
      #         knowledge: :none,
      #         module: :generator
      #       },
      #       links: {
      #         github_url: "#"
      #       }
      #     },
      #     {
      #       title: "Write Boolean concept exercise for Python track",
      #       isNew: true,
      #       track: {
      #         title: Track.first.title,
      #         icon_url: Track.first.icon_url
      #       },
      #       tags: {
      #         action: :fix,
      #         type: :docker,
      #         size: :tiny,
      #         knowledge: :none,
      #         module: :representer
      #       },
      #       links: {
      #         github_url: "#"
      #       }
      #     },
      #     {
      #       title: "Write Boolean concept exercise for Python track",
      #       isNew: true,
      #       track: {
      #         title: Track.first.title,
      #         icon_url: Track.first.icon_url
      #       },
      #       tags: {
      #         action: :fix,
      #         type: :docker,
      #         size: :tiny,
      #         knowledge: :none,
      #         module: :concept
      #       },
      #       links: {
      #         github_url: "#"
      #       }
      #     },

      #     {
      #       title: "Write Boolean concept exercise for Python track",
      #       isNew: true,
      #       track: {
      #         title: Track.first.title,
      #         icon_url: Track.first.icon_url
      #       },
      #       tags: {},
      #       links: {
      #         github_url: "#"
      #       }
      #     }
      #   ]
      # }
    end
  end
end
