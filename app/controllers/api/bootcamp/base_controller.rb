class API::Bootcamp::BaseController < API::BaseController
  # TODO: Move this to a middleware that explodes this out
  #  during the actual parameter parsing.
  def params
    raw = request.parameters
    return raw unless request.content_type == "application/json"
    return raw unless raw[:_json].present?

    raw.merge!(JSON.parse(raw.delete(:_json)))
    raw
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
