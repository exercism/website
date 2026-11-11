class API::V1::FilesController < API::BaseController
  before_action :require_authentication_header!

  def show
    begin
      solution = Solution.find_by!(uuid: params[:solution_id])
    rescue ActiveRecord::RecordNotFound
      return render_solution_not_found
    end

    return render_403(:solution_not_accessible) unless solution.viewable_by?(current_user)

    if solution.user == current_user
      submission = solution.submissions.last
    elsif solution.viewable_as_mentor_by?(current_user)
      submission = solution.latest_iteration_submission
    else
      submission = solution.latest_published_iteration_submission
    end

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
