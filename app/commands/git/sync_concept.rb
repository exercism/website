module Git
  class SyncConcept
    include Mandate
    initialize_with :concept

    def call
      fetch_git_data!
      sync! unless synced_to_head?
    end

    private
    attr_reader :synced_git_concept, :head_git_concept, :head_git_track

    def fetch_git_data!
      git_repo = Git::Repository.new(concept.track.slug, repo_url: concept.track.repo_url)
      git_repo.update!

      @synced_git_concept = Git::Concept.new(concept.track.slug, concept.slug, concept.synced_to_git_sha, repo: git_repo)
      @head_git_concept = Git::Concept.new(concept.track.slug, concept.slug, git_repo.head_sha, repo: git_repo)
      @head_git_track = Git::Track.new(concept.track.slug, git_repo.head_sha, repo: git_repo)
    end

    def synced_to_head?
      synced_git_concept.commit.oid == head_git_concept.commit.oid
    end

    def sync!
      return concept.update!(synced_to_git_sha: head_git_concept.commit.oid) unless concept_modified?

      concept.update!(
        slug: config_concept[:slug],
        name: config_concept[:name],
        blurb: config_concept[:blurb],
        synced_to_git_sha: head_git_concept.commit.oid
      )
    end

    def concept_modified?
      return false unless track_config_modified?

      config_concept[:slug] != concept.slug ||
        config_concept[:name] != concept.name ||
        config_concept[:blurb] != concept.blurb
    end

    def track_config_modified?
      return false if synced_git_concept.commit.oid == head_git_concept.commit.oid

      diff = head_git_concept.commit.diff(synced_git_concept.commit)
      diff.each_delta.any? do |delta|
        delta.old_file[:path] == head_git_track.config_filepath ||
          delta.new_file[:path] == head_git_track.config_filepath
      end
    end

    memoize
    def config_concept
      # TODO: determine what to do when the concept could not be found
      head_git_track.config[:concepts].find { |e| e[:uuid] == concept.uuid }
    end
  end
end
