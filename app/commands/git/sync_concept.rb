module Git
  class SyncConcept
    include Mandate
    initialize_with :concept

    def call
      lookup_head_and_current_commit
      update_concept! unless concept_synced_to_head?
    end

    private
    attr_reader :current_commit, :head_commit

    def lookup_head_and_current_commit
      concept.git.update!

      @current_commit = concept.git.lookup_commit(concept.synced_to_git_sha)
      @head_commit = concept.git.head_commit
    end

    def concept_synced_to_head?
      current_commit.oid == head_commit.oid
    end

    def update_concept!
      return concept.update!(synced_to_git_sha: head_commit.oid) unless concept_modified?

      concept.update!(
        slug: config_concept[:slug],
        name: config_concept[:name],
        synced_to_git_sha: head_commit.oid
      )
    end

    def concept_modified?
      return false unless track_config_modified?

      config_concept[:slug] != concept.slug ||
        config_concept[:name] != concept.name
    end

    def track_config_modified?
      return false if current_commit.oid == head_commit.oid

      diff.each_delta.any? do |delta|
        delta.old_file[:path] == concept.track.git.config_filepath ||
          delta.new_file[:path] == concept.track.git.config_filepath
      end
    end

    memoize
    def config_concept
      # TODO: determine what to do when the concept could not be found
      head_config = concept.track.git.config(commit: head_commit)
      head_config[:concepts].find { |e| e[:uuid] == concept.uuid }
    end

    memoize
    def diff
      head_commit.diff(current_commit)
    end
  end
end
