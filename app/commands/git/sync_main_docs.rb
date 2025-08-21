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
  end

  memoize
  def repo
    Git::Docs.new(branch_ref: ENV['GIT_DOCS_BRANCH'])
  end
end
