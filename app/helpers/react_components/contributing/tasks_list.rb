module ReactComponents
  module Contributing
    class TasksList < ReactComponent
      extend Mandate::Memoize

      initialize_with :params

      def to_s
        super(
          "contributing-tasks-list",
          {
            request: {
              endpoint: Exercism::Routes.api_tasks_url,
              query:,
              options: {
                initial_data: AssembleTasks.(params)
              }
            },
            tracks: AssembleTracksForSelect.()
          }
        )
      end

      private
      memoize
      def query
        {
          actions: params[:actions] || [],
          knowledge: params[:knowledge] || [],
          areas: params[:areas] || [],
          sizes: params[:sizes] || [],
          types: params[:types] || [],
          repo_url: params[:repo_url] || "",
          track_slug: params[:track_slug] || "",
          order: params[:order] || "newest",
          page: params[:page] || 1
        }
      end
    end
  end
end
