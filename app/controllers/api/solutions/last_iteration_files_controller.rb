module API
  module Solutions
    class LastIterationFilesController < BaseController
      def index
        begin
          solution = Solution.find_by!(uuid: params[:solution_uuid])
        rescue ActiveRecord::RecordNotFound
          return render_solution_not_found
        end

        return render_403(:solution_not_accessible) unless current_user.may_view_solution?(solution)
        return render_400(:no_iterations_submitted_yet) if solution.latest_iteration.blank?

        files = solution.latest_iteration.files_for_editor

        render json: { files: SerializeFiles.(files) }
      end
    end
  end
end
