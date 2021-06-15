require "test_helper"

class Concept::ContributorshipTest < ActiveSupport::TestCase
  test "wired in correctly" do
    concept = create :track_concept
    user = create :user
    contributorship = create :concept_contributorship,
      concept: concept,
      contributor: user

    assert_equal concept, contributorship.concept
    assert_equal user, contributorship.contributor
  end
end
