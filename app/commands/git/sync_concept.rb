class Git::SyncConcept < Git::Sync
  include Mandate

  def initialize(concept, force_sync: false)
    super(concept.track, concept.synced_to_git_sha)

    @concept = concept
    @force_sync = force_sync
  end

  def call
    return concept.update_columns(synced_to_git_sha: head_git_concept.synced_git_sha) unless force_sync || concept_needs_updating?

    concept.update!(
      slug: concept_config[:slug],
      name: concept_config[:name],
      blurb: head_git_concept.blurb,
      synced_to_git_sha: head_git_concept.synced_git_sha
    )

    # Capture this before the syncs below re-save the concept and reset its
    # dirty tracking.
    content_changed = concept.saved_changes.except(*IGNORED_CHANGES).present?

    Git::SyncConceptAuthors.(concept)
    Git::SyncConceptContributors.(concept)

    # Only purge when something a visitor can see actually changed. A
    # force-sync re-saves every concept on every track, and purging all of
    # those would burn through Cloudflare's rate limits for nothing.
    Concept::InvalidateCloudflareCache.defer(concept) if content_changed
  end

  private
  attr_reader :concept, :force_sync

  def concept_needs_updating?
    track_config_concept_modified? || concept_config_modified?
  end

  def track_config_concept_modified?
    return false unless track_config_modified?

    concept_config[:slug] != concept.slug ||
      concept_config[:name] != concept.name ||
      head_git_concept.blurb != concept.blurb
  end

  def concept_config_modified?
    return false unless filepath_in_diff?(head_git_concept.config_absolute_filepath)

    head_git_concept.blurb != concept.blurb ||
      head_git_concept.authors.to_a.sort != concept.authors.map(&:github_username).sort ||
      head_git_concept.contributors.to_a.sort != concept.contributors.map(&:github_username).sort
  end

  memoize
  def concept_config
    # TODO: (Optional) determine what to do when the concept could not be found
    head_git_track.find_concept(concept.uuid)
  end

  memoize
  def head_git_concept
    Git::Concept.new(concept_config[:slug], git_repo.head_sha, repo: git_repo)
  end
end
