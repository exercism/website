module Git
  class SyncMainDocs
    include Mandate

    def call
      sync_config! :using
      sync_config! :contributing
      sync_config! :mentoring
    end

    private
    def sync_config!(section)
      repo.fetch!
      config = repo.read_json_blob(repo.head_commit, "#{section}/config.json")

      config.to_a.each do |doc_config|
        Git::SyncDoc.(doc_config, section)
      end
    end

    memoize
    def repo
      # TODO: Put a constant somewhere for this (also used in sync_doc)
      Git::Repository.new(repo_url: "https://github.com/exercism/docs")
    end
  end
end
