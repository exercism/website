class Git::SyncExerciseArticle
  include Mandate

  initialize_with :exercise, :config, :position

  def call
    find_or_create!.tap do |article|
      article.update!(attributes_for_update(article))
    end
  end

  private
  def find_or_create!
    Exercise::Article.find_create_or_find_by!(uuid: config[:uuid]) do |article|
      article.attributes = attributes_for_create
    end
  end

  def attributes_for_create
    config.slice(:slug, :title, :blurb).
      merge({ exercise:, position:, synced_to_git_sha: exercise.git.head_sha })
  end

  def attributes_for_update(article)
    attributes_for_create.merge({
      authorships: authorships(article),
      contributorships: contributorships(article)
    })
  end

  def authorships(article)
    ::User.with_data.where(data: { github_username: config[:authors].to_a }).
      map { |author| ::Exercise::Article::Authorship::Create.(article, author) }
  end

  def contributorships(article)
    ::User.with_data.where(data: { github_username: config[:contributors].to_a }).
      map { |contributor| ::Exercise::Article::Contributorship::Create.(article, contributor) }
  end
end
