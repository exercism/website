module ReactComponents
  module Contributing
    class TasksList < ReactComponent
      extend Mandate::Memoize

      def initialize(params)
        super()

        @params = params
      end

      def to_s
        super(
          "contributing-tasks-list",
          {
            request: {
              endpoint: Exercism::Routes.api_tasks_url,
              query: query,
              options: {
                initial_data: initial_data
              }
            }
          }
        )
      end

      private
      attr_reader :params

      memoize
      def initial_data
        AssembleTasks.(params)
      end

      memoize
      def query
        q = {}
        q[:actions] = params[:actions] if params[:actions].present?
        q[:knowledge] = params[:knowledge] if params[:knowledge].present?
        q[:areas] = params[:areas] if params[:areas].present?
        q[:sizes] = params[:sizes] if params[:sizes].present?
        q[:types] = params[:types] if params[:types].present?
        q[:repo_url] = params[:repo_url] if params[:repo_url].present?
        q[:track_id] = params[:track_id] if params[:track_id].present?
        q[:order] = params[:order] if params[:order].present?
        q[:page] = initial_data[:meta][:current_page]
        q
      end
    end
  end
end
