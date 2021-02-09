module API
  class MentorDiscussionsController < BaseController
    # TODO: Add filters
    def index
      discussions = ::Solution::MentorDiscussion::Retrieve.(
        current_user,
        page: params[:page],
        track_slug: params[:track],
        criteria: params[:criteria],
        order: params[:order]
      )

      render json: SerializePaginatedCollection.(
        discussions,
        SerializeMentorDiscussions
      )
    end

    def tracks
      track_counts = Solution::MentorDiscussion::Retrieve.(current_user).
        group(:track_id).count
      tracks = Track.where(id: track_counts.keys).index_by(&:id)
      data = track_counts.map do |track_id, count|
        track = tracks[track_id]
        {
          slug: track.slug,
          title: track.title,
          icon_url: track.icon_url,
          count: count
        }
      end

      render json: [
        {
          slug: nil,
          title: 'All',
          icon_url: Track.first.icon_url,
          count: track_counts.values.sum
        }
      ].concat(data)
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
  end
end
