require "test_helper"

class MarkSolutionsAsOutOfDateInIndexJobTest < ActiveJob::TestCase
  test "solutions are marked as out of date" do
    exercise = create :practice_exercise
    Exercise::MarkSolutionsAsOutOfDateInIndex.expects(:call).with(exercise)

    MarkSolutionsAsOutOfDateInIndexJob.perform_now(exercise)
  end
end
