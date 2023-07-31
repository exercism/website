class Git::SyncTrackDocs < Git::Sync
  include Mandate

  def initialize(track, force_sync: false)
    super(track, track.synced_to_git_sha)
    @force_sync = force_sync
  end

  def call
    return unless force_sync || filepath_in_diff?("docs/config.json")

    config = git_repo.read_json_blob(git_repo.head_commit, "docs/config.json")

    config[:docs].to_a.each do |doc_config|
      Git::SyncDoc.(doc_config, :tracks, git_repo.head_commit.oid, track:)
    end
  end

  private
  attr_reader :force_sync
end
