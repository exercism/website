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

        files = solution.latest_iteration.files.map do |file|
          {
            filename: file.filename,
            content: file.content,
            digest: file.digest
          }
        end

        render json: { files: files }
      end
    end
  end
end
