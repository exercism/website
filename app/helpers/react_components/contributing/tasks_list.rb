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
              query: query,
              options: {
                initial_data: AssembleTasks.(params)
              }
            }
          }.merge(AssembleTrackSwitcher.())
        )
      end

      private
      memoize
      def query
        {
          actions: params[:actions],
          knowledge: params[:knowledge],
          areas: params[:areas],
          sizes: params[:sizes],
          types: params[:types],
          repo_url: params[:repo_url],
          track: params[:track],
          order: params[:order],
          page: params[:page]
        }.compact
      end
    end
  end
end
