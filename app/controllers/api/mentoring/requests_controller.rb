module API
  class Mentoring::RequestsController < BaseController
    def index
      begin
        if params[:track_slug].present?
          track_id = Track.find(params[:track_slug]).id
          current_user.track_mentorships.update_all("last_viewed = (track_id = #{track_id})")
        end
      rescue StandardError
        # We can have an invalid track_slug here.
      end

      render json: AssembleMentorRequests.(current_user, params)
    end

    def tracks
      render json: Mentor::Request::RetrieveTracks.(current_user)
    end

    def exercises
      render json: Mentor::Request::RetrieveExercises.(current_user, params[:track_slug])
    end

    def lock
      mentor_request = Mentor::Request.find_by(uuid: params[:uuid])
      return render_404(:mentor_request_not_found) unless mentor_request

      Mentor::Request::Lock.(mentor_request, current_user)

      render json: {
        request: SerializeMentorSessionRequest.(mentor_request)
      }
    end
  end
end
