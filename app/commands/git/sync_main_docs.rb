module Git
  class SyncMainDocs
    include Mandate

    def call
      repo.fetch!

      sync_config! :using
      sync_config! :building
      sync_config! :mentoring
      sync_config! :community
    end

    private
    def sync_config!(section)
      config = repo.read_json_blob(repo.head_commit, "#{section}/config.json")

      config.to_a.each do |doc_config|
        Git::SyncDoc.(doc_config, section, repo.head_commit.oid)
      end
    end

    memoize
    def repo
      Git::Repository.new(repo_url: Document::REPO_URL)
    end
  end
end
