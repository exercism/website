require "test_helper"

class Exercise::Approach::ContributorshipTest < ActiveSupport::TestCase
  test "wired in correctly" do
    contributor = create :user
    approach = create :exercise_approach

    contributorship = create(:exercise_approach_contributorship, approach:, contributor:)

    assert_equal contributor, contributorship.contributor
    assert_equal approach, contributorship.approach
  end
end
