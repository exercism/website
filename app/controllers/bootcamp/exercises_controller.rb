class Bootcamp::ExercisesController < Bootcamp::BaseController
  before_action :use_project, only: %i[show edit]
  before_action :use_exercise, only: %i[show edit]

  def index
    @projects = Bootcamp::Project.all
    unless current_user.bootcamp_data.enrolled_in_both_parts?
      if current_user.bootcamp_data.enrolled_on_part_1?
        @projects = @projects.part_1
      elsif current_user.bootcamp_data.enrolled_on_part_2?
        @projects = @projects.part_2
      end
    end

    @projects = @projects.index_with do |project|
      exercises = project.exercises.unlocked
      unless current_user.bootcamp_data.enrolled_in_both_parts?
        if current_user.bootcamp_data.enrolled_on_part_1?
          exercises = exercises.part_1
        elsif current_user.bootcamp_data.enrolled_on_part_2?
          exercises = exercises.part_2
        end
      end
      exercises
    end
    @solutions = current_user.bootcamp_solutions.where(exercise: @exercises).index_by(&:exercise_id)
  end

  def show
    redirect_to action: :edit
  end

  def edit
    @solution = Bootcamp::Solution::Create.(current_user, @exercise)
  rescue ExerciseLockedError
    redirect_to action: :show
  end

  def use_exercise
    @exercise = @project.exercises.find_by!(slug: params[:slug])
  end
end
