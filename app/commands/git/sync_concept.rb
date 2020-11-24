module Git
  class SyncConcept
    include Mandate
    initialize_with :concept

    def call
      lookup_head_commit
      update_concept! if concept_modified?
    end

    private
    attr_reader :head_commit

    def lookup_head_commit
      concept.git.update!
      @head_commit = concept.git.head_commit
    end

    def update_concept!
      concept.update!(
        slug: config_concept[:slug],
        name: config_concept[:name]
      )
    end

    def concept_modified?
      config_concept[:slug] != concept.slug ||
        config_concept[:name] != concept.name
    end

    memoize
    def config_concept
      # TODO: determine what to do when the concept could not be found
      head_config = concept.track.git.config(commit: head_commit)
      head_config[:concepts].find { |e| e[:uuid] == concept.uuid }
    end
  end
end
