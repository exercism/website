class Mentoring::RequestsController < ApplicationController
  before_action :ensure_mentor!

  before_action :use_mentor_request
  before_action :disable_site_header!

  def show
    if @mentor_request.pending?
      return redirect_to action: :unavailable unless @mentor_request.lockable_by?(current_user)

    elsif @mentor_request.fulfilled?
      discussion = @mentor_request.discussion
      return redirect_to action: :unavailable unless discussion&.mentor_id == current_user.id

      redirect_to mentoring_discussion_path(discussion)
    else
      # TODO: Handle cancelled requests
      redirect_to action: :unavailable
    end
  end

  def unavailable
    render status: :not_found
  end

  private
  def use_mentor_request
    @mentor_request = Mentor::Request.find_by!(uuid: params[:id])
  end
end
