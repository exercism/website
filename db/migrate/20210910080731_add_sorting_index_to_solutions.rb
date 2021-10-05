class AddSortingIndexToSolutions < ActiveRecord::Migration[6.1]
  def up
    sql = <<-SQL
      CREATE INDEX solutions_popular_new 
      ON solutions
      (num_stars DESC, id DESC)
    SQL

    execute(sql)
  end

  def down
    execute("DROP INDEX solutions_popular_new ON solutions")
  end
end
