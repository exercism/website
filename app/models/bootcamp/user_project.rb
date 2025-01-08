class Bootcamp::UserProject < ApplicationRecord
  extend Mandate::Memoize

  self.table_name = "bootcamp_user_projects"

  belongs_to :user
  belongs_to :project, class_name: "Bootcamp::Project"

  enum :status, { locked: 0, available: 1, completed: 2 }

  def status = super.to_sym
  def locked? = status == :locked
  def available? = status == :available
  def completed? = status == :completed

  def self.for!(user, project)
    find_by!(user:, project:)
  end

  # memoize
  def solutions
    Bootcamp::Solution.where(user:, exercise: project.exercises).
      includes(:exercise).
      to_a
  end

  def unlocked_exercises
    project.exercises.reject { |e| e.locked?(user) }
  end

  def next_exercise
    completed_exercise_ids = solutions.select(&:completed?).map(&:exercise_id)
    project.exercises.reject { |e| e.locked?(user) }.reject { |e| completed_exercise_ids.include?(e.id) }.first
  end

  def exercise_available?(exercise)
    # If the project's locked, all the exercises are locked
    return false if locked?

    # If the exercise is gloabally locked, it's locked
    return false if exercise.locked?(user)

    # The first exercise is always available
    return true if exercise.idx == 1

    # Otherwise the previous solution must be completed
    solutions.find { |s| s.exercise.idx == exercise.idx - 1 }&.completed?
  end

  def exercise_status(exercise, solution)
    solution ||= solutions.find { |s| s.exercise_id == exercise.id }

    if solution
      solution.status
    elsif exercise_available?(exercise)
      :available
    else
      :locked
    end
  end
end
