class AnalyzeTablesJob < ApplicationJob
  queue_as :dribble

  def perform
    Infrastructure::AnalyzeTable.(User.table_name)
  end
end
