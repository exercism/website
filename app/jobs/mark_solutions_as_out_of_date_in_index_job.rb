class MarkSolutionsAsOutOfDateInIndexJob < ApplicationJob
  queue_as :default

  def perform(exercise)
    Solution::MarkAsOutOfDateInIndex.(exercise)
  end
end
