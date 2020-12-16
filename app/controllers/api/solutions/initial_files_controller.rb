module API
  module Solutions
    class InitialFilesController < BaseController
      def index
        solution = current_user.solutions.find_by!(uuid: params[:solution_id])

        files = SerializeFiles.(solution.initial_files)

        render json: { files: files }
      end
    end
  end
end
