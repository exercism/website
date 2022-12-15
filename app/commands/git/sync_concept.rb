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

    Git::SyncConceptAuthors.(concept)
    Git::SyncConceptContributors.(concept)
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
