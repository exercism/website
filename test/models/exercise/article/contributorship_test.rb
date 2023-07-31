require "test_helper"

class Exercise::Article::ContributorshipTest < ActiveSupport::TestCase
  test "wired in correctly" do
    contributor = create :user
    article = create :exercise_article

    contributorship = create(:exercise_article_contributorship, article:, contributor:)

    assert_equal contributor, contributorship.contributor
    assert_equal article, contributorship.article
    assert_includes article.contributorships, contributorship
    assert_includes article.contributors, contributor
  end
end
