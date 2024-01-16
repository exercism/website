class Exercise::CacheNumPublishedSolutions < ApplicationJob
  include Mandate

  queue_as :default

  initialize_with :exercise

  def call
    sql = Arel.sql(exercise.solutions.published.select("COUNT(*)").to_sql)

    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      Exercise.where(id: exercise.id).update_all("num_published_solutions = (#{sql})")
    end
  end
end
