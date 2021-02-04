module API
  class MentorRequestsController < BaseController
    def index
      unscoped_total = ::Solution::MentorRequest::Retrieve.(
        current_user,
        page: params[:page],
        track_slug: params[:track_id],
        exercise_slugs: params[:exercise_ids],
        sorted: false, paginated: false
      ).count

      requests = ::Solution::MentorRequest::Retrieve.(
        current_user,
        page: params[:page],
        track_slug: params[:track_id],
        exercise_slugs: params[:exercise_ids]
      )

      render json: SerializePaginatedCollection.(
        requests,
        SerializeMentorRequests,
        meta: {
          unscoped_total: unscoped_total
        }
      )
    end

    def tracks
      render json: Solution::MentorRequest::RetrieveTracks.(current_user)
    end

    def exercises
      render json: Solution::MentorRequest::RetrieveExercises.(current_user, params[:track_id])
    end

    def lock
      mentor_request = Solution::MentorRequest.find_by(uuid: params[:id])
      return render_404(:mentor_request_not_found) unless mentor_request

      Solution::MentorRequest::Lock.(mentor_request, current_user)
    end
  end
end
