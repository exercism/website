class Bootcamp::SelectNextExercise
  include Mandate

  initialize_with :user, project: nil

  def call
    return next_user_project_exercise if next_user_project_exercise

    Bootcamp::Exercise.unlocked.where.not(project: user.bootcamp_projects).
      where.not(id: completed_exercise_ids).first
  end

  def user_project
    if project
      user_project = Bootcamp::UserProject.for!(user, project)
      return user_project if user_project.available?
    end

    user.bootcamp_user_projects.where(status: :available).first
  end

  memoize
  def next_user_project_exercise = user_project&.next_exercise

  def completed_exercise_ids
    user.bootcamp_solutions.where.not(completed_at: nil).select(:exercise_id)
  end
end
