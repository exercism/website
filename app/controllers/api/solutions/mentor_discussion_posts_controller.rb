# TODO: Check to see which parts of this and
# api/mentoring/discussion_posts can be DRYed up
module API
  class Solutions::MentorDiscussionPostsController < BaseController
    before_action :use_mentor_discussion

    def index
      mentor_request_comment = MentorRequestComment.from(@discussion)
      posts = @discussion.posts

      serialized_posts = [mentor_request_comment, *posts].
        compact.
        map { |post| SerializeMentorDiscussionPost.(post, current_user) }

      render json: { posts: serialized_posts }
    end

    def create
      post = Mentor::Discussion::ReplyByStudent.(
        @discussion,
        @discussion.iterations.last,
        params[:content]
      )

      DiscussionPostListChannel.notify!(@discussion)

      render json: { post: SerializeMentorDiscussionPost.(post, current_user) }
    end

    def update
      post = Mentor::DiscussionPost.find_by(uuid: params[:id])

      return render_404(:mentor_discussion_post_not_found) if post.blank?
      return render_403(:mentor_discussion_post_not_accessible) unless post.author == current_user

      if post.update(content_markdown: params[:content])
        DiscussionPostListChannel.notify!(post.discussion)
        render json: { post: SerializeMentorDiscussionPost.(post, current_user) }
      else
        render_400(:failed_validations, errors: post.errors)
      end
    end

    private
    def use_mentor_discussion
      @discussion = Mentor::Discussion.find_by(uuid: params[:discussion_id])
      return render_404(:mentor_discussion_not_found) unless @discussion

      @solution = @discussion.solution
      return render_403(:mentor_discussion_not_accessible) unless @solution.user_id == current_user.id
    end
  end

  # TOOD: Merge itno the other identical place
  class MentorRequestComment
    include ActiveModel::Model

    attr_accessor :uuid, :author, :by_student, :content_markdown, :content_html, :iteration_idx, :updated_at, :discussion

    def self.from(discussion)
      mentor_request = discussion.request
      # TODO: Add tests
      return nil unless mentor_request
      return nil if mentor_request.comment_html.present?

      if discussion.posts.any?
        iteration_idx = discussion.posts.first.iteration_idx
      else
        iteration_idx = discussion.iterations.last.idx
      end

      new(
        uuid: "",
        iteration_idx: iteration_idx,
        author: mentor_request.user,
        by_student: true,
        content_markdown: mentor_request.comment_markdown,
        content_html: mentor_request.comment_html,
        updated_at: mentor_request.updated_at,
        discussion: discussion
      )
    end

    def by_student?
      by_student
    end

    def links
      {}
    end
  end
end
