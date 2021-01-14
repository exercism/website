module API
  class MentorDiscussionPostsController < BaseController
    before_action :use_mentor_discussion, only: %i[index create]

    def index
      posts = @discussion.posts

      serialized_posts = posts.map { |post| SerializeMentorDiscussionPost.(post, current_user) }

      render json: { posts: serialized_posts }
    end

    def create
      attrs = [
        @discussion,
        @discussion.iterations.last,
        params[:content]
      ]

      post = case current_user
             when @discussion.mentor
               Solution::MentorDiscussion::ReplyByMentor.(*attrs)
             when @discussion.student
               Solution::MentorDiscussion::ReplyByStudent.(*attrs)
             end

      DiscussionPostListChannel.notify!(@discussion)

      render json: { post: SerializeMentorDiscussionPost.(post, current_user) }
    end

    def update
      post = Solution::MentorDiscussionPost.find_by(uuid: params[:id])

      return render_404(:mentor_discussion_post_not_found) if post.blank?
      return render_403(:permission_denied) unless post.author == current_user

      if post.update(content_markdown: params[:content])
        DiscussionPostListChannel.notify!(post.discussion)
        render json: { post: SerializeMentorDiscussionPost.(post, current_user) }
      else
        render_400(:failed_validations, errors: post.errors)
      end
    end

    private
    def use_mentor_discussion
      @discussion = Solution::MentorDiscussion.find_by(uuid: params[:mentor_discussion_id])
      return render_404(:mentor_discussion_not_found) unless @discussion
      return render_403(:mentor_discussion_not_accessible) unless @discussion.viewable_by?(current_user)
    end
  end
end
