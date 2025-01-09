class Git::SyncBootcampContent
  include Mandate

  queue_as :default

  def call
    repo.update!

    repo.levels.each do |data|
      level = Bootcamp::Level.find_or_create_by!(idx: data.idx) do |l|
        l.title = data.title
        l.description = data.description
        l.content_markdown = data.content
      end
      level.update(
        title: data.title,
        description: data.description,
        content_markdown: data.content
      )
    rescue StandardError => e
      raise if Rails.env.development?

      Bugsnag.notify(e)
    end

    repo.concepts.each do |data|
      concept = Bootcamp::Concept.find_or_create_by!(uuid: data.uuid) do |c|
        c.slug = data.slug
        c.title = data.title
        c.description = data.description
        c.level_idx = data.level
        c.apex = data.apex
      end
      concept.update(
        slug: data.slug,
        title: data.title,
        description: data.description,
        level_idx: data.level,
        apex: data.apex
      )
    rescue StandardError => e
      raise if Rails.env.development?

      Bugsnag.notify(e)
    end
  end

  private
  delegate :head_commit, to: :repo

  memoize
  def repo = Git::BootcampContent.new
end
