class Git::SyncTrackDocs < Git::Sync
  include Mandate

  def initialize(track)
    super(track, track.synced_to_git_sha)
  end

  def call
    return unless filepath_in_diff?("docs/config.json")

    config = git_repo.read_json_blob(git_repo.head_commit, "docs/config.json")

    config[:docs].to_a.each do |doc_config|
      Git::SyncDoc.(doc_config, :tracks, git_repo.head_commit.oid, track:)
    end
  end
end
