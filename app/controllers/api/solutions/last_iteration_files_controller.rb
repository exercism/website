class API::Solutions::LastIterationFilesController < API::BaseController
  def index
    begin
      solution = Solution.find_by!(uuid: params[:solution_uuid])
    rescue ActiveRecord::RecordNotFound
      return render_solution_not_found
    end

    return render_403(:solution_not_accessible) unless current_user.id == solution.user_id
    return render_400(:no_iterations_submitted_yet) if solution.latest_iteration.blank?

    files = solution.latest_iteration.files_for_editor

    render json: { files: SerializeFilesWithMetadata.(files) }
  end
end
