class API::Solutions::InitialFilesController < API::BaseController
  def index
    begin
      solution = Solution.find_by!(uuid: params[:solution_uuid])
    rescue ActiveRecord::RecordNotFound
      return render_solution_not_found
    end

    return render_403(:solution_not_accessible) unless current_user.id == solution.user_id

    files = SerializeFilesWithMetadata.(solution.exercise_files_for_editor)

    render json: { files: }
  end
end
