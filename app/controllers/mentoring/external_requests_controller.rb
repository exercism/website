class Mentoring::ExternalRequestsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :use_solution

  def show
    return render action: :show_logged_out unless user_signed_in?

    # Redirect to mentor queue if this is your own request
    return redirect_to Exercism::Routes.private_solution_path(@solution) if @solution.user == current_user

    return render action: :show_not_mentor unless current_user.mentor?
  end

  def accept
    existing_discussion = @solution.mentor_discussions.find_by(mentor: current_user)
    return redirect_to mentoring_discussion_path(existing_discussion) if existing_discussion

    # TODO: (Optional): Move this into a command
    # and make it less horrible!
    discussion = Mentor::Request.transaction do
      request = Mentor::Request.create!(
        solution: @solution,
        comment_markdown: "This is a private review session"
      )
      request.fulfilled!
      Mentor::Discussion.create!(
        mentor: current_user,
        request:,
        awaiting_student_since: Time.current
      )
    end

    redirect_to mentoring_discussion_path(discussion)
  end

  private
  def use_solution
    @solution = Solution.find_by!(public_uuid: params[:uuid])
  end
end
