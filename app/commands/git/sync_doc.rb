module Git
  class SyncDoc
    include Mandate

    def initialize(config, section, track: nil)
      @config = config
      @track = track
      @section = section
    end

    def call
      doc = Document.where(track: track).create_or_find_by!(
        uuid: config[:uuid],
        track: track
      ) { |d| d.attributes = attributes }

      doc.update!(attributes)
    rescue StandardError
      # TODO: Raise issue on GH.
    end

    private
    attr_reader :config, :section, :track

    def repo_url
      # TODO: Put a constant somewhere for this
      track ? track.repo_url : "https://github.com/exercism/docs"
    end

    def attributes
      {
        slug: config[:slug],
        git_repo: repo_url,
        git_path: config[:path],
        section: section,
        title: config[:title],
        blurb: config[:blurb]
      }
    end
  end
end
