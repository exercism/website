require "test_helper"

class Exercise::Article::AuthorshipTest < ActiveSupport::TestCase
  test "wired in correctly" do
    author = create :user
    article = create :exercise_article

    authorship = create(:exercise_article_authorship, article:, author:)

    assert_equal author, authorship.author
    assert_equal article, authorship.article
    assert_includes article.authorships, authorship
    assert_includes article.authors, author
  end
end
