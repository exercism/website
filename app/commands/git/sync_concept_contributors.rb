class Git::SyncConceptContributors < Git::Sync
  include Mandate

  def initialize(concept)
    super(concept.track, concept.synced_to_git_sha)
    @concept = concept
  end

  def call
    ActiveRecord::Base.transaction do
      contributors = ::User.with_data.where(data: { github_username: contributors_config })
      contributors.find_each { |contributor| ::Concept::Contributorship::Create.(concept, contributor) }

      # This is required to remove contributors that were already added
      concept.reload.update!(contributors:)

      # TODO: (Optional) consider what to do with missing contributors
      missing_contributors = contributors_config - contributors.map(&:github_username)
      Rails.logger.error "Missing contributors: #{missing_contributors.join(', ')}" if missing_contributors.present?
    end
  end

  private
  attr_reader :concept

  memoize
  def contributors_config
    head_git_concept.contributors.to_a
  end

  memoize
  def head_git_concept
    concept_config = head_git_track.find_concept(concept.uuid)
    Git::Concept.new(concept_config[:slug], git_repo.head_sha, repo: git_repo)
  end
end
