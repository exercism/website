module API
  class V1::FilesController < BaseController
    def show
      begin
        solution = Solution.find_by!(uuid: params[:solution_id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_403(:solution_not_accessible) unless solution.viewable_by?(current_user)

      if solution.user == current_user
        file = solution.submissions.last.files.where(filename: params[:filepath]).first if solution.submissions.last
      else
        file = solution.latest_iteration.submission.files.where(filename: params[:filepath]).first
      end

      content = file&.content

      unless content
        begin
          content = solution.read_file(params[:filepath])
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
