module API
  class Solutions::MentorRequestsController < BaseController
    before_action :use_solution

    def create
      mentor_request = Mentor::Request::Create.(
        @solution,
        params[:comment]
      )

      render json: {
        mentor_request: SerializeMentorSessionRequest.(mentor_request)
      }
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
