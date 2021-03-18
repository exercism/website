module Git
  class SyncTrackDocs < Sync
    include Mandate

    def initialize(track)
      super(track, track.synced_to_git_sha)
    end

    def call
      return unless filepath_in_diff?("docs/config.json")

      config = git_repo.read_json_blob(git_repo.head_commit, "docs/config.json")

      config[:docs].to_a.each do |doc_config|
        doc = Document.where(track: track).create_or_find_by!(
          uuid: doc_config[:uuid],
          track: track
        ) do |d|
          d.slug = doc_config[:slug]
          d.git_repo = track.repo_url
          d.git_path = doc_config[:path]
          d.title = doc_config[:title]
        end

        doc.update!(
          slug: doc_config[:slug],
          git_path: doc_config[:path],
          title: doc_config[:title],
          blurb: doc_config[:blurb]
        )
      rescue StandardError
        # TODO: Raise issue on GH.
      end
    end
  end
end
