module API
  class MentorDiscussionsController < BaseController
    def create
      mentor_request = Solution::MentorRequest.find_by(uuid: params[:mentor_request_id])
      return render_404(:mentor_request_not_found) unless mentor_request

      begin
        Solution::MentorDiscussion::Create.(
          current_user,
          mentor_request,
          params[:iteration_idx],
          params[:content]
        )
      rescue SolutionLockedByAnotherMentorError
        return render_400(:mentor_request_locked)
      end

      # TODO: Return the discussion here
      head 200
    end
  end
end
