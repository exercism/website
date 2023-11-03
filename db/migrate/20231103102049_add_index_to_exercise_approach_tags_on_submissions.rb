class AddIndexToExerciseApproachTagsOnSubmissions < ActiveRecord::Migration[7.0]
  def up
    return if Rails.env.production?

    sql = <<-SQL
    CREATE INDEX `index_submissions_exercise_approach_tags` 
    ON `submissions` (`exercise_id`, `approach_id`, (JSON_VALUE(tags, '$[0]' NULL ON EMPTY)))
    SQL

    execute(sql)
  end

  def down
    return if Rails.env.production?

    execute("DROP INDEX `index_submissions_exercise_approach_tags` ON `submissions`")
  end
end
