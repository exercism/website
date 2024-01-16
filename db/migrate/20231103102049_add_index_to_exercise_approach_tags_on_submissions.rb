class AddIndexToExerciseApproachTagsOnSubmissions < ActiveRecord::Migration[7.0]
  def up
    # We don't want to run this in development as it
    # screws up the schema. We *DO* want to run it in production
    # but not via the migrations. So we just return in all circumstances.
    return

    sql = <<-SQL
    CREATE INDEX `index_submissions_exercise_approach_tags`
    ON `submissions` (`exercise_id`, `approach_id`, (JSON_VALUE(tags, '$[0]' NULL ON EMPTY)))
    SQL

    execute(sql)
  end

  def down
    return

    execute("DROP INDEX `index_submissions_exercise_approach_tags` ON `submissions`")
  end
end
