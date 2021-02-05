module API
  class MentorDiscussionsController < BaseController
    # TODO: Add filters
    def index
      discussions = ::Solution::MentorDiscussion::Retrieve.(
        current_user,
        params[:page]
      )
      render json: SerializeMentorDiscussions.(discussions)
    end

    # TODO: Merge this into the query above
    def tracks
      discussions = ::Solution::MentorDiscussion::Retrieve.(current_user, 1)
      render json: discussions.tracks.map { |track|
        {
          id: track.id, # TODO: This should probably be slug
          title: track.title,
          iconUrl: "https://assets.exercism.io/tracks/ruby-hex-white.png"
        }
      }
    end

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

    def mark_as_nothing_to_do
      discussion = ::Solution::MentorDiscussion.find_by(uuid: params[:id])

      return render_404(:mentor_discussion_not_found) if discussion.blank?
      return render_403(:mentor_discussion_not_accessible) unless discussion.viewable_by?(current_user)
      return render_403(:mentor_discussion_not_accessible) unless current_user == discussion.mentor

      discussion.mentor_action_not_required!

      render json: {}
    end

    # TODO: An actual implementation of this endpoint. The JSON response below is what I expect for the React component.
    def finish
      discussion = ::Solution::MentorDiscussion.find_by(uuid: params[:id])
      discussion.update!(finished_at: Time.current)
      relationship = Mentor::StudentRelationship.find_or_create_by!(mentor: discussion.mentor, student: discussion.student)

      render json: {
        discussion: {
          student: {
            handle: discussion.student.handle
          },
          relationship: SerializeMentorStudentRelationship.(relationship)
        }
      }
    end
  end
end
