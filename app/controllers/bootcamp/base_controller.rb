class Bootcamp::BaseController < ApplicationController
  layout "bootcamp-ui"
  before_action :redirect_unless_attendee!

  private
  def redirect_unless_attendee!
    return if current_user&.bootcamp_attendee?
    return if current_user&.bootcamp_mentor?

    redirect_to bootcamp_path
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
