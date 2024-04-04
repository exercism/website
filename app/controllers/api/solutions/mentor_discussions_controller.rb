class API::Solutions::MentorDiscussionsController < API::BaseController
  before_action :use_mentor_discussion

  # TODO
  def finish
    Mentor::Discussion::FinishByStudent.(
      @discussion,
      params[:rating],
      requeue: params[:requeue],
      report: params[:report],
      block: params[:block],
      report_reason: params[:report_reason],
      report_message: params[:report_message],
      testimonial: params[:testimonial]
    )

    render json: {}
  end

  private
  def use_mentor_discussion
    @discussion = Mentor::Discussion.find_by(uuid: params[:uuid])
    return render_404(:mentor_discussion_not_found) unless @discussion

    @solution = @discussion.solution
    render_403(:mentor_discussion_not_accessible) unless @solution.user_id == current_user.id
  end
end
