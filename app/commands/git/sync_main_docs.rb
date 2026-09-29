class Git::SyncMainDocs
  include Mandate

  queue_as :default

  def call
    repo.fetch!

    sync_config! :using
    sync_config! :building
    sync_config! :programming
    sync_config! :mentoring
    sync_config! :community
  end

  private
  def sync_config!(section)
    config = repo.section_config(section)

    config.to_a.each_with_index do |doc_config, position|
      Git::SyncDoc.(doc_config, section, position, repo.head_sha)
    end

    remove_deleted_docs!(section, config.to_a.map { |doc_config| doc_config[:uuid] })
  end

  # A doc removed from a section's config.json would otherwise stay on the site
  # for ever. An empty config is taken as a failed read, never as a section
  # with no docs, so it removes nothing.
  def remove_deleted_docs!(section, uuids)
    return if uuids.empty?

    Document.where(track: nil, section:).where.not(uuid: uuids).destroy_all
  end

  memoize
  def repo
    Git::Docs.new(branch_ref: ENV['GIT_DOCS_BRANCH'])
  end
end
