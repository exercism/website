# TODO: (Optional) Check to see which parts of this and
# api/mentoring/discussion_posts can be DRYed up
class API::Solutions::MentorDiscussionPostsController < API::BaseController
  before_action :use_mentor_discussion

  def index
    mentor_request_comment = @discussion.request_comment
    posts = @discussion.posts

    serialized_posts = [mentor_request_comment, *posts].
      compact.
      map { |post| SerializeMentorDiscussionPost.(post, current_user) }

    render json: { items: serialized_posts }
  end

  def create
    post = Mentor::Discussion::ReplyByStudent.(
      @discussion,
      @discussion.iterations.last,
      params[:content]
    )

    DiscussionPostListChannel.notify!(@discussion)

    render json: { item: SerializeMentorDiscussionPost.(post, current_user) }
  end

  def update
    post = Mentor::DiscussionPost.find_by(uuid: params[:uuid])

    return render_404(:mentor_discussion_post_not_found) if post.blank?
    return render_403(:mentor_discussion_post_not_accessible) unless post.author == current_user

    if post.update(content_markdown: params[:content])
      DiscussionPostListChannel.notify!(post.discussion)
      render json: { item: SerializeMentorDiscussionPost.(post, current_user) }
    else
      render_400(:failed_validations, errors: post.errors)
    end
  end

  def destroy
    post = Mentor::DiscussionPost.find_by(uuid: params[:uuid])

    return render_404(:mentor_discussion_post_not_found) if post.blank?
    return render_403(:mentor_discussion_post_not_accessible) unless post.author == current_user

    post.destroy

    DiscussionPostListChannel.notify!(post.discussion)
    render json: { item: SerializeMentorDiscussionPost.(post, current_user) }
  end

  private
  def use_mentor_discussion
    @discussion = Mentor::Discussion.find_by(uuid: params[:discussion_uuid])
    return render_404(:mentor_discussion_not_found) unless @discussion

    @solution = @discussion.solution
    render_403(:mentor_discussion_not_accessible) unless @solution.user_id == current_user.id
  end
end
