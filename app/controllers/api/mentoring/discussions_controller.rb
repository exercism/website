class API::Mentoring::DiscussionsController < API::BaseController
  include Propshaft::Helper

  # TODO: (Optional) Add filters (the criteria aren't the filters?)
  def index
    begin
      discussions = ::Mentor::Discussion::Retrieve.(
        current_user,
        params[:status],
        page: params[:page],
        track_slug: params[:track_slug],
        student_handle: params[:student],
        criteria: params[:criteria],
        exclude_uuid: params[:exclude_uuid],
        order: params[:order]
      )
    rescue InvalidDiscussionStatusError
      return render_error(400, :invalid_discussion_status)
    end

    if sideload?(:all_discussion_counts)
      meta = {
        awaiting_mentor_total: current_user.mentor_discussions.awaiting_mentor.count,
        awaiting_student_total: current_user.mentor_discussions.awaiting_student.count,
        finished_total: current_user.mentor_discussions.finished_for_mentor.count
      }
    end

    render json: SerializePaginatedCollection.(
      discussions,
      serializer: SerializeMentorDiscussionsForMentor,
      serializer_args: current_user,
      meta: meta || {}
    )
  end

  def tracks
    track_counts = Mentor::Discussion::Retrieve.(
      current_user,
      params[:status],
      sorted: false, paginated: false
    ).joins(solution: { exercise: :track }).group(:track_id).count

    tracks = Track.where(id: track_counts.keys).order(:title)
    data = tracks.map do |track|
      SerializeTrackForSelect.(track).merge(count: track_counts[track.id])
    end

    render json: [
      SerializeTrackForSelect::ALL_TRACK.merge(count: track_counts.values.sum),
      *data
    ]
  end

  def create
    mentor_request = Mentor::Request.find_by(uuid: params[:mentor_request_uuid])
    return render_404(:mentor_request_not_found) unless mentor_request

    begin
      discussion = Mentor::Discussion::Create.(
        current_user,
        mentor_request,
        params[:iteration_idx],
        params[:content]
      )
    rescue StudentCannotMentorThemselvesError
      return render_400(:student_cannot_mentor_themselves)
    rescue SolutionLockedByAnotherMentorError
      return render_400(:mentor_request_locked)
    end

    render json: {
      discussion: {
        id: discussion.uuid,
        is_finished: discussion.finished_for_mentor?,
        links: {
          self: Exercism::Routes.mentoring_discussion_url(discussion),
          posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion),
          mark_as_nothing_to_do: Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_url(discussion),
          finish: Exercism::Routes.finish_api_mentoring_discussion_url(discussion)
        }
      }
    }
  end

  def mark_as_nothing_to_do
    discussion = ::Mentor::Discussion.find_by(uuid: params[:uuid])

    return render_404(:mentor_discussion_not_found) if discussion.blank?
    return render_403(:mentor_discussion_not_accessible) unless discussion.viewable_by?(current_user)
    return render_403(:mentor_discussion_not_accessible) unless current_user == discussion.mentor

    Mentor::Discussion::AwaitingStudent.(discussion)

    render json: {
      id: discussion.uuid
    }
  end

  # TODO: (Required) An actual implementation of this endpoint.
  # The JSON response below is what I expect for the React component.
  def finish
    discussion = current_user.mentor_discussions.find_by(uuid: params[:uuid])
    Mentor::Discussion::FinishByMentor.(discussion)
    relationship = Mentor::StudentRelationship.find_create_or_find_by!(mentor: discussion.mentor, student: discussion.student)

    render json: {
      discussion: {
        id: discussion.uuid,
        student: SerializeStudent.(
          discussion.student,
          discussion.mentor,
          user_track: UserTrack.for(discussion.student, discussion.track),
          relationship:,
          anonymous_mode: discussion.anonymous_mode?
        ),
        is_finished: true,
        links: {
          posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion)
        }
      }
    }
  end
end
