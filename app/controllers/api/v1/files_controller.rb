class API::V1::FilesController < API::BaseController
  def show
    begin
      solution = Solution.find_by!(uuid: params[:solution_id])
    rescue ActiveRecord::RecordNotFound
      return render_solution_not_found
    end

    return render_403(:solution_not_accessible) unless solution.viewable_by?(current_user)

    submission = solution.user == current_user ?
      solution.submissions.last :
      solution.latest_iteration&.submission

    content = submission.files.find_by(filename: params[:filepath])&.content if submission

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
