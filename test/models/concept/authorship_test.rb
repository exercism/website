require "test_helper"

class Concept::AuthorshipTest < ActiveSupport::TestCase
  test "wired in correctly" do
    concept = create :track_concept
    user = create :user
    authorship = create :concept_authorship,
      concept: concept,
      author: user

    assert_equal concept, authorship.concept
    assert_equal user, authorship.author
  end
end
