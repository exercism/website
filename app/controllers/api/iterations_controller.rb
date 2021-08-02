module API
  class IterationsController < BaseController
    before_action :use_solution

    def latest_status
      render json: {
        status: @solution.latest_iteration.status.to_s
      }
    end

    def create
      begin
        submission = @solution.submissions.find_by!(uuid: params[:submission_uuid])
      rescue ActiveRecord::RecordNotFound
        return render_submission_not_found
      end

      iteration = Iteration::Create.(@solution, submission)

      render json: {
        iteration: SerializeIteration.(iteration)
      }, status: :created
    end

    # TODO
    def destroy
      iteration = @solution.iterations.find_by(uuid: params[:uuid])

      iteration.update!(deleted_at: Time.current)

      render json: {
        iteration: SerializeIteration.(iteration)
      }
    end

    private
    def use_solution
      begin
        @solution = Solution.find_by!(uuid: params[:solution_uuid])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless @solution.user_id == current_user.id
    end
  end
end
