module API
  class Mentoring::DiscussionsController < BaseController
    include Propshaft::Helper

    # TODO: (Optional) Add filters (the criteria aren't the filters?)
    def index
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

      if sideload?(:all_discussion_counts)
        all_discussions = Mentor::Discussion.
          joins(solution: :exercise).
          where(mentor: current_user)

        meta = {
          awaiting_mentor_total: all_discussions.awaiting_mentor.count,
          awaiting_student_total: all_discussions.awaiting_student.count,
          finished_total: all_discussions.finished_for_mentor.count
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
      ).group(:track_id).count

      tracks = Track.where(id: track_counts.keys).index_by(&:id)
      data = track_counts.map do |track_id, count|
        track = tracks[track_id]

        SerializeTrackForSelect.(track).merge(count:)
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

      discussion.awaiting_student!

      render json: {
        id: discussion.uuid
      }
    end

    # TODO: (Required) An actual implementation of this endpoint.
    # The JSON response below is what I expect for the React component.
    def finish
      discussion = current_user.mentor_discussions.find_by(uuid: params[:uuid])
      discussion.mentor_finished!
      relationship = Mentor::StudentRelationship.find_or_create_by!(mentor: discussion.mentor, student: discussion.student)

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
end
