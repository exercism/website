module API
  class MentorDiscussionPostsController < BaseController
    before_action :use_mentor_discussion

    def create
      attrs = [
        @discussion,
        params[:iteration_idx],
        params[:content]
      ]

      case current_user
      when @discussion.mentor
        Solution::MentorDiscussion::ReplyByMentor.(*attrs)
      when @discussion.student
        Solution::MentorDiscussion::ReplyByStudent.(*attrs)
      else
        return render_403
      end

      # TODO: Return the discussion post here
      head 200
    end

    private
    def use_mentor_discussion
      @discussion = Solution::MentorDiscussion.find_by(uuid: params[:mentor_discussion_id])
      render_404(:mentor_discussion_not_found) unless @discussion
    end
  end
end
