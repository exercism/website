class Bootcamp::Solution::Create
  include Mandate

  initialize_with :user, :exercise

  def call
    guard!

    begin
      Bootcamp::Solution.create!(
        user:,
        exercise:,
        code:
      )
    rescue ActiveRecord::RecordNotUnique
      Bootcamp::Solution.find_by!(
        user:,
        exercise:
      )
    end
  end

  private
  def guard!
    raise ExerciseLockedError unless user_project.exercise_available?(exercise)
  end

  def code
    exercise.stub.gsub(Regexp.new("{{EXERCISE_([-a-z0-9]+)}}")) do
      previous_solutions[::Regexp.last_match(1)].code
    end
  end

  # This is used for the code interpolation, only if actually required.
  memoize
  def previous_solutions
    user_project.solutions.index_by { |s| s.exercise.slug }
  end

  memoize
  def user_project
    Bootcamp::UserProject.find_by!(user:, project: exercise.project)
  rescue StandardError
    Bootcamp::UserProject::Create.(user, exercise.project)
  end
end
