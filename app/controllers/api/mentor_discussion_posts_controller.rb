module API
  class MentorDiscussionPostsController < BaseController
    before_action :use_mentor_discussion, only: %i[index create]

    def index
      posts = @discussion.
        posts.
        joins(:iteration).
        where(iterations: { idx: params[:iteration_idx] })

      render json: posts.map { |post| SerializeMentorDiscussionPost.(post, current_user) }
    end

    def create
      iteration = @discussion.solution.iterations.find_by(idx: params[:iteration_idx])

      return render_404(:iteration_not_found) if iteration.blank?

      attrs = [
        @discussion,
        iteration,
        params[:content]
      ]

      case current_user
      when @discussion.mentor
        Solution::MentorDiscussion::ReplyByMentor.(*attrs)
      when @discussion.student
        Solution::MentorDiscussion::ReplyByStudent.(*attrs)
      end

      DiscussionPostListChannel.notify!(@discussion, iteration)

      # TODO: Return the discussion post here
      head 200
    end

    def update
      post = Solution::MentorDiscussionPost.find_by(uuid: params[:id])

      return render_404(:mentor_discussion_post_not_found) if post.blank?
      return render_403(:permission_denied) unless post.author == current_user

      return unless post.update(content_markdown: params[:content])

      DiscussionPostListChannel.notify!(post.discussion, post.iteration)

      render json: SerializeMentorDiscussionPost.(post, current_user)
    end

    private
    def use_mentor_discussion
      @discussion = Solution::MentorDiscussion.find_by(uuid: params[:mentor_discussion_id])
      return render_404(:mentor_discussion_not_found) unless @discussion
      return render_403(:mentor_discussion_not_accessible) unless @discussion.viewable_by?(current_user)
    end
  end
end
