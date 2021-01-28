module API
  module Solutions
    class InitialFilesController < BaseController
      def index
        begin
          solution = Solution.find_by!(uuid: params[:solution_id])
        rescue ActiveRecord::RecordNotFound
          return render_solution_not_found
        end

        return render_403(:solution_not_accessible) unless current_user.may_view_solution?(solution)

        files = SerializeFiles.(solution.exercise_solution_files)

        render json: { files: files }
      end
    end
  end
end
