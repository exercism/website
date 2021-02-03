module API
  class MentorRequestsController < BaseController
    def index
      requests = ::Solution::MentorRequest::Retrieve.(
        current_user,
        params[:page],
        track_id: params[:track_id],
        exercise_ids: params[:exercise_ids]
      )
      render json: SerializePaginatedCollection.(
        requests,
        SerializeMentorRequests,
        meta: {
          query_total: 50
        }
      )
    end

    def lock
      mentor_request = Solution::MentorRequest.find_by(uuid: params[:id])
      return render_404(:mentor_request_not_found) unless mentor_request

      Solution::MentorRequest::Lock.(mentor_request, current_user)
    end
  end
end
