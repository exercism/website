class Infrastructure::AnalyzeTable
  include Mandate

  initialize_with :table_name

  def call
    ActiveRecord::Base.connection.execute("ANALYZE TABLE #{table_name};")
  end
end
