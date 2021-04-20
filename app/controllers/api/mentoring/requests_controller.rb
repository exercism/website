module API
  class Mentoring::RequestsController < BaseController
    def index
      unscoped_total = ::Mentor::Request::Retrieve.(
        mentor: current_user,
        page: params[:page],
        track_slug: params[:track_slug],
        exercise_slug: params[:exercise_slug],
        sorted: false,
        paginated: false
      ).count

      requests = ::Mentor::Request::Retrieve.(
        mentor: current_user,
        page: params[:page],
        criteria: params[:criteria],
        order: params[:order],
        track_slug: params[:track_slug],
        exercise_slug: params[:exercise_slug]
      )

      if params[:track_slug].present?
        begin
          track_id = Track.find(params[:track_slug]).id
          current_user.track_mentorships.update_all("last_viewed = (track_id = #{track_id})")
        rescue StandardError
          # We can have an invalid track_slug here.
        end
      end

      render json: SerializePaginatedCollection.(
        requests,
        serializer: SerializeMentorRequests,
        meta: {
          unscoped_total: unscoped_total
        }
      )
    end

    def tracks
      render json: Mentor::Request::RetrieveTracks.(current_user)
    end

    def exercises
      render json: Mentor::Request::RetrieveExercises.(current_user, params[:track_slug])
    end

    def lock
      mentor_request = Mentor::Request.find_by(uuid: params[:id])
      return render_404(:mentor_request_not_found) unless mentor_request

      Mentor::Request::Lock.(mentor_request, current_user)

      render json: {
        request: SerializeMentorSessionRequest.(mentor_request)
      }
    end
  end
end
