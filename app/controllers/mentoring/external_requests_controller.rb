class Mentoring::ExternalRequestsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :use_solution

  def show
    return render action: :show_logged_out unless user_signed_in?

    # Redirect to solution if this is your own solution
    return redirect_to Exercism::Routes.private_solution_path(@solution) if @solution.user == current_user

    render action: :show_not_mentor unless current_user.mentor?
  end

  def accept
    existing_discussion = @solution.mentor_discussions.in_progress_for_student.find_by(mentor: current_user)
    return redirect_to mentoring_discussion_path(existing_discussion) if existing_discussion

    discussion = Mentor::Request::AcceptExternal.(current_user, @solution)
    redirect_to mentoring_discussion_path(discussion)
  end

  private
  def use_solution
    @solution = Solution.find_by!(public_uuid: params[:uuid])
  end
end
