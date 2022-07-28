class CacheNumPublishedSolutionsOnExerciseJob < ApplicationJob
  queue_as :default

  def perform(exercise)
    sql = Arel.sql(exercise.solutions.published.select("COUNT(*)").to_sql)

    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      Exercise.where(id: exercise.id).update_all("num_published_solutions = (#{sql})")
    end
  end
end
