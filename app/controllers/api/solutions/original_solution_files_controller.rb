module API
  module Solutions
    class OriginalSolutionFilesController < BaseController
      def index
        solution = current_user.solutions.find_by!(uuid: params[:solution_id])

        files = SerializeFiles.(solution.original_solution_files)

        render json: { files: files }
      end
    end
  end
end
