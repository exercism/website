module API
  module Solutions
    class MentorRequestsController < BaseController
      def lock
        mentor_request = Solution::MentorRequest.find_by(uuid: params[:id])
        return render_404(:mentor_request_not_found) unless mentor_request

        Solution::MentorRequest::Lock.(mentor_request, current_user)
      end
    end
  end
end
