class Exercise::Article::Authorship::Create
  include Mandate

  initialize_with :article, :author

  def call
    article.authorships.find_create_or_find_by!(author:).tap do |authorship|
      User::ReputationToken::Create.defer(author, :exercise_article_author, authorship:)
    end
  end
end
