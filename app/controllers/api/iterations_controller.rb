module API
  class IterationsController < BaseController
    def latest_status
      solution = Solution.find_by!(uuid: params[:id])

      render json: {
        status: solution.latest_iteration.status.to_s
      }
    end

    def create
      begin
        solution = Solution.find_by!(uuid: params[:solution_id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless solution.user_id == current_user.id

      begin
        submission = solution.submissions.find_by!(uuid: params[:submission_id])
      rescue ActiveRecord::RecordNotFound
        return render_submission_not_found
      end

      iteration = Iteration::Create.(solution, submission)

      render json: {
        iteration: SerializeIteration.(iteration)
      }, status: :created
    end
  end
end
