class MarkSolutionsAsOutOfDateInIndexJob < ApplicationJob
  queue_as :default

  def perform(exercise)
    Exercise::MarkSolutionsAsOutOfDateInIndex.(exercise)
  end
end
