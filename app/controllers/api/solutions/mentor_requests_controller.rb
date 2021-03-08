module API
  class Solutions::MentorRequestsController < BaseController
    before_action :use_solution

    def create
      Solution::MentorRequest::Create.(
        @solution,
        params[:comment]
      )
      render json: {}
    end

    private
    def use_solution
      begin
        @solution = Solution.find_by!(uuid: params[:solution_id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless @solution.user_id == current_user.id
    end
  end
end
