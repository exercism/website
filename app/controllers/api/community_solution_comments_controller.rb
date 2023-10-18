class API::CommunitySolutionCommentsController < API::BaseController
  before_action :use_solution
  before_action :guard_accessible!, only: %i[index create]

  def index
    render json: AssembleCommunitySolutionsCommentsList.(@solution, current_user)
  end

  def create
    comment = Solution::Comment::Create.(
      current_user,
      @solution,
      params[:content]
    )

    render json: { item: SerializeSolutionComment.(comment, current_user) }
  end

  def update
    comment = Solution::Comment.find_by(uuid: params[:uuid])

    return render_404(:solution_comment_not_found) if comment.blank?
    return render_403(:solution_comment_not_accessible) unless comment.author == current_user

    if comment.update(content_markdown: params[:content])
      # TODO: Readd this
      # CommentListChannel.notify!(comment.solution)
      render json: { item: SerializeSolutionComment.(comment, current_user) }
    else
      render_400(:failed_validations, errors: comment.errors)
    end
  end

  def destroy
    comment = Solution::Comment.find_by(uuid: params[:uuid])

    return render_404(:solution_comment_not_found) if comment.blank?
    return render_403(:solution_comment_not_accessible) unless comment.author == current_user

    if comment.destroy
      # TODO: Readd this
      # CommentListChannel.notify!(comment.solution)
      render json: { item: SerializeSolutionComment.(comment, current_user) }
    else
      render_400(:solution_comment_not_deleted)
    end
  end

  def enable
    @solution.update!(allow_comments: true)

    render json: {}
  end

  def disable
    @solution.update!(allow_comments: false)

    render json: {}
  end

  private
  def use_solution
    @track = Track.find(params[:track_slug])
    @exercise = @track.exercises.find(params[:exercise_slug])
    user = User.find_by!(handle: params[:community_solution_handle])
    @solution = @exercise.solutions.find_by!(user_id: user.id)
  rescue ActiveRecord::RecordNotFound
    render_solution_not_found
  end

  def guard_accessible!
    return if @solution.published? && @solution.allow_comments?

    render_403(:solution_comments_not_allowed)
  end
end
