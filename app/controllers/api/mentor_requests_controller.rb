module API
  class MentorRequestsController < BaseController
    def index
      unscoped_total = ::Solution::MentorRequest::Retrieve.(
        current_user,
        page: params[:page],
        track_slug: params[:track_slug],
        exercise_slugs: params[:exercise_slugs],
        sorted: false,
        paginated: false
      ).count

      requests = ::Solution::MentorRequest::Retrieve.(
        current_user,
        page: params[:page],
        criteria: params[:criteria],
        order: params[:order],
        track_slug: params[:track_slug],
        exercise_slugs: params[:exercise_slugs]
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
      render json: Solution::MentorRequest::RetrieveExercises.(current_user, params[:track_slug])
    end

    def lock
      mentor_request = Solution::MentorRequest.find_by(uuid: params[:id])
      return render_404(:mentor_request_not_found) unless mentor_request

      Solution::MentorRequest::Lock.(mentor_request, current_user)

      render json: {
        request: {
          id: mentor_request.uuid,
          comment: mentor_request.comment,
          updated_at: mentor_request.updated_at.iso8601,
          is_locked: mentor_request.locked?,
          links: {
            lock: Exercism::Routes.lock_api_mentor_request_path(mentor_request),
            discussion: Exercism::Routes.api_mentor_discussions_path
          }
        }
      }
    end
  end
end
