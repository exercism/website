require "test_helper"

class Concept::AuthorshipTest < ActiveSupport::TestCase
  test "wired in correctly" do
    concept = create :concept
    user = create :user
    authorship = create :concept_authorship,
      concept:,
      author: user

    assert_equal concept, authorship.concept
    assert_equal user, authorship.author
  end
end
