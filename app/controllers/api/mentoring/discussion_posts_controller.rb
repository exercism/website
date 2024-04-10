class API::Mentoring::DiscussionPostsController < API::BaseController
  before_action :use_mentor_discussion

  def index
    mentor_request_comment = @discussion.request_comment
    posts = @discussion.posts.includes(
      :iteration,
      :author
    )

    serialized_posts = [mentor_request_comment, posts].
      flatten.
      compact.
      map { |post| SerializeMentorDiscussionPost.(post, current_user) }

    render json: { items: serialized_posts }
  end

  def create
    post = Mentor::Discussion::ReplyByMentor.(
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

    if post.destroy
      DiscussionPostListChannel.notify!(post.discussion)
      render json: { item: SerializeMentorDiscussionPost.(post, current_user) }
    else
      render_400(:mentor_discussion_post_not_deleted)
    end
  end

  private
  def use_mentor_discussion
    @discussion = Mentor::Discussion.find_by(uuid: params[:discussion_uuid])
    return render_404(:mentor_discussion_not_found) unless @discussion

    render_403(:mentor_discussion_not_accessible) unless @discussion.viewable_by_mentor?(current_user)
  end
end
