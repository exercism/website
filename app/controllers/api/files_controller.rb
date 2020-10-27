module API
  class FilesController < BaseController
    def show
      begin
        solution = Solution.find_by!(uuid: params[:solution_id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_403(:solution_not_accessible) unless current_user.may_view_solution?(solution)

      if solution.submissions.last
        file = solution.submissions.last.files.where(filename: params[:filepath]).first
        content = file&.content
      end

      unless content
        begin
          content = Git::Exercise.for_solution(solution).file(params[:filepath])
        rescue StandardError
          return render_file_not_found
        end
      end

      # Should this be content.present? ie should we 404 on empty files?
      return render_file_not_found unless content

      render plain: content
    end
  end
end
