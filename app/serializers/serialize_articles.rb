class SerializeArticles
  include Mandate

  initialize_with :articles

  def call
    articles_with_track.map do |article|
      SerializeArticle.(article, authors(article), contributors(article))
    end
  end

  private
  memoize
  def articles_with_track = articles.includes(:track).to_a

  def authors(article)
    users.select { |user| article_author_ids[article.id]&.include?(user.id) }
  end

  def contributors(article)
    users.select { |user| article_contributor_ids[article.id]&.include?(user.id) }
  end

  memoize
  def article_author_ids
    Exercise::Article::Authorship.
      where(article: articles_with_track).
      pluck(:exercise_article_id, :user_id).
      group_by(&:first).
      transform_values { |values| values.map(&:second) }
  end

  memoize
  def article_contributor_ids
    Exercise::Article::Contributorship.
      where(article: articles_with_track).
      pluck(:exercise_article_id, :user_id).
      group_by(&:first).
      transform_values { |values| values.map(&:second) }
  end

  memoize
  def users
    User.includes(:profile).
      where(id: article_author_ids.values.flatten + article_contributor_ids.values.flatten).
      to_a
  end

  class SerializeArticle
    include Mandate

    initialize_with :article, :authors, :contributors

    def call
      {
        users: CombineAuthorsAndContributors.(authors, contributors).map do |user|
          SerializeAuthorOrContributor.(user)
        end,
        num_authors: authors.count,
        num_contributors: contributors.count,
        slug: article.slug,
        title: article.title,
        blurb: article.blurb,
        snippet_html: article.snippet_html,
        links: {
          self: Exercism::Routes.track_exercise_article_path(article.track, article.exercise, article)
        }
      }
    end
  end
end
