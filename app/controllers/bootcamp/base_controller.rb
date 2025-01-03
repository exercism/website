class Bootcamp::BaseController < ApplicationController
  layout "bootcamp-ui"

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
