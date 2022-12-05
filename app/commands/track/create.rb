class Track::Create
  include Mandate

  initialize_with :repo_url

  def call
    Track.create!(
      slug: git_track.slug,
      repo_url:,
      title: git_track.title,
      blurb: git_track.blurb,
      tags: git_track.tags,
      synced_to_git_sha: git_track.head_sha
    ).tap do |track|
      # We need to force_sync due to the synced_to_git_sha value set to the HEAD commit
      Git::SyncTrack.(track, force_sync: true)
      Track::CreateForumCategory.(track)
    end
  rescue ActiveRecord::RecordNotUnique
    Track.find_by!(slug: git_track.slug)
  end

  memoize
  def git_track = Git::Track.new("HEAD", repo_url:)
end
