require 'test_helper'

class SerializeSolutionsForStudentTest < ActiveSupport::TestCase
  test "basic to_hash" do
    solution = create :practice_solution, published_at: Time.current - 1.week
    create :submission, solution: solution

    create :user_track, user: solution.user, track: solution.track
    expected = [SerializeSolutionForStudent.(solution)]

    assert_equal expected, SerializeSolutionsForStudent.(Solution.all)
  end
end
