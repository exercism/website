require "test_helper"

class Exercise::CacheNumPublishedSolutionsTest < ActiveSupport::TestCase
  test "shouldn't touch exercises's updated_at" do
    original_time = Time.current - 6.months
    exercise = create :practice_exercise, updated_at: original_time, median_wait_time: 100

    Exercise::CacheNumPublishedSolutions.(exercise)
    assert_equal original_time, exercise.reload.updated_at
  end
end
