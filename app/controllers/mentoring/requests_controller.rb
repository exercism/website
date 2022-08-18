class Mentoring::RequestsController < ApplicationController
  before_action :ensure_mentor!

  before_action :use_mentor_request

  def show
    # Redirect to mentor queue if this is your own request
    return redirect_to mentoring_queue_path if @mentor_request.student_id == current_user.id

    # Handle cancelled requests
    return redirect_to action: :unavailable if @mentor_request.cancelled?

    # Handle locked solutions
    return redirect_to action: :unavailable if @mentor_request.pending? && !@mentor_request.lockable_by?(current_user)

    # Handle already-fulfilled solutions
    if @mentor_request.fulfilled? # rubocop:disable Style/GuardClause
      discussion = @mentor_request.discussion
      return redirect_to action: :unavailable unless discussion&.mentor_id == current_user.id

      redirect_to mentoring_discussion_path(discussion)
    end
  end

  def unavailable
    render status: :not_found
  end

  private
  def use_mentor_request
    @mentor_request = Mentor::Request.find_by!(uuid: params[:uuid])
  end
end
