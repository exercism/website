class Exercise::Article::Contributorship::Create
  include Mandate

  initialize_with :article, :contributor

  def call
    article.contributorships.find_create_or_find_by!(contributor:).tap do |contributorship|
      User::ReputationToken::Create.defer(contributor, :exercise_article_contribution, contributorship:)
    end
  end
end
