require "test_helper"

class Exercise::Approach::AuthorshipTest < ActiveSupport::TestCase
  test "wired in correctly" do
    author = create :user
    approach = create :exercise_approach

    authorship = create(:exercise_approach_authorship, approach:, author:)

    assert_equal author, authorship.author
    assert_equal approach, authorship.approach
  end
end
