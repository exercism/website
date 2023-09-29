class API::Mentoring::RequestsController < API::BaseController
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
      request: SerializeMentorSessionRequest.(mentor_request, current_user)
    }
  end

  def extend_lock
    mentor_request = Mentor::Request.find_by(uuid: params[:uuid])
    return render_404(:mentor_request_not_found) unless mentor_request

    lock = Mentor::RequestLock.find_by(request_id: mentor_request.id)
    lock.extend!
    # TODO: Catch raised exception from out of date lock and return accordingly

    render json: {
      mentor_request_lock: {
        locked_until: lock.locked_until
      }
    }
  rescue RequestLockHasExpired
    render json: { error: "Lock has expired" }, status: :unprocessable_entity
  end

  def cancel
    mentor_request = current_user.solution_mentor_requests.find_by(uuid: params[:uuid])
    return render_404(:mentor_request_not_found) unless mentor_request

    Mentor::Request::Cancel.(mentor_request)

    render json: {
      links: {
        home: Exercism::Routes.track_exercise_mentor_discussions_path(mentor_request.track, mentor_request.exercise)
      }
    }
  end
end
