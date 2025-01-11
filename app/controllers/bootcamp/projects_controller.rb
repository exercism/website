class Bootcamp::ProjectsController < Bootcamp::BaseController
  before_action :use_project, only: %i[show]

  def index
    @user_projects = current_user.bootcamp_user_projects.index_by(&:project_id)
  end

  def show
    @exercises = @project.exercises
    @solutions = current_user.bootcamp_solutions.where(exercise: @exercises).index_by(&:exercise_id)
  end

  def use_project
    @project = Bootcamp::Project.find_by!(slug: params[:slug])
    redirect_to action: :index if @project.locked?

    begin
      @user_project = current_user.bootcamp_user_projects.find_by!(project: @project)
    rescue StandardError
      @user_project = Bootcamp::UserProject::Create.(current_user, @project)
    end
  end
end
