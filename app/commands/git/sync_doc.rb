module Git
  class SyncDoc
    include Mandate

    def initialize(config, section, git_sha, track: nil)
      @config = config
      @track = track
      @section = section
      @git_sha = git_sha
    end

    def call
      doc = Document.where(track:).create_or_find_by!(
        uuid: config[:uuid],
        track:
      ) { |d| d.attributes = attributes }

      doc.update!(attributes)
    rescue StandardError => e
      Github::Issue::OpenForDocSyncFailure.(config, section, e, git_sha)
    end

    private
    attr_reader :config, :section, :track, :git_sha

    def repo_url
      track ? track.repo_url : Document::REPO_URL
    end

    def attributes
      {
        slug: config[:slug],
        git_repo: repo_url,
        git_path: config[:path],
        section:,
        title: config[:title],
        blurb: config[:blurb]
      }
    end
  end
end
