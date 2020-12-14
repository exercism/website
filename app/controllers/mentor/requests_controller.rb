class Mentor::RequestsController < ApplicationController
  before_action :use_mentor_request

  def show
    return redirect_to action: :unavailable unless @mentor_request.lockable_by?(current_user)
  end

  def unavailable
    render status: :not_found
  end

  private
  def use_mentor_request
    @mentor_request = Solution::MentorRequest.find(params[:id])
  end
end
