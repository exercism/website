class Bootcamp::BaseController < ApplicationController
  layout "bootcamp"
  before_action :redirect_to_english!
  before_action :redirect_unless_attendee!
  before_action :setup_bootcamp_data!

  private
  def redirect_unless_attendee!
    return if current_user&.bootcamp_attendee?
    return if current_user&.bootcamp_mentor?

    if session[:course_access_code].present?
      return redirect_to new_user_session_path unless user_signed_in?

      enrollment = CourseEnrollment.find_by(access_code: session[:course_access_code])
      return redirect_to bootcamp_path unless enrollment

      enrollment.link_to_user!(current_user)
      return if current_user.bootcamp_attendee?
    end

    redirect_to bootcamp_path
  end

  def setup_bootcamp_data!
    return if current_user.bootcamp_data

    current_user.create_bootcamp_data!
    # Bootcamp::UpdateUserLevel.(current_user, 1)
    # Bootcamp::UpdateUserLevel.(current_user, 2)
  end

  def use_project
    @project = Bootcamp::Project.find_by!(slug: params[:project_slug])
  end

  def use_exercise
    @exercise = @project.exercises.find_by!(slug: params[:exercise_slug])
  end

  def use_solution
    @solution = current_user.bootcamp_solutions.find_by!(uuid: params[:solution_uuid])
  end
end
