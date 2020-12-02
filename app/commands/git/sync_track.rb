module Git
  class SyncTrack < Sync
    include Mandate

    def initialize(track)
      super(track, track.synced_to_git_sha)
      @track = track
    end

    def call
      update_git_repo!
      super
    end

    private
    attr_reader :track

    def sync!
      return track.update!(synced_to_git_sha: head_git_track.commit.oid) unless track_needs_updating?

      # TODO: consider raising error when slug in config is different from track slug
      # TODO: validate track to prevent invalid track data
      track.update!(
        blurb: head_git_track.config[:blurb],
        active: head_git_track.config[:active],
        title: head_git_track.config[:language],
        synced_to_git_sha: head_git_track.commit.oid,
        concepts: concepts,
        concept_exercises: concept_exercises,
        practice_exercises: practice_exercises
      )

      track.concepts.each { |concept| Git::SyncConcept.(concept) }
      track.concept_exercises.each { |concept_exercise| Git::SyncExercise.(concept_exercise) }
      track.practice_exercises.each { |practice_exercise| Git::SyncExercise.(practice_exercise) }
    end

    def concepts
      # TODO: verify that all exercise concepts and prerequisites are in the concepts section
      config_concepts.map do |config_concept|
        ::Track::Concept::Create.(
          config_concept[:uuid],
          track,
          slug: config_concept[:slug],
          name: config_concept[:name],
          blurb: config_concept[:blurb],
          synced_to_git_sha: head_git_track.commit.oid
        )
      end
    end

    def concept_exercises
      config_concept_exercises.map do |exercise|
        ::ConceptExercise::Create.(
          exercise[:uuid],
          track,
          slug: exercise[:slug],
          title: exercise[:name], # TODO: the DB used title, config.json used name. Consider if we want this
          taught_concepts: find_concepts(exercise[:concepts]),
          prerequisites: find_concepts(exercise[:prerequisites]),
          deprecated: exercise[:deprecated] || false,
          git_sha: head_git_track.commit.oid,
          synced_to_git_sha: head_git_track.commit.oid
        )
      end
    end

    def practice_exercises
      config_practice_exercises.map do |exercise|
        ::PracticeExercise::Create.(
          exercise[:uuid],
          track,
          slug: exercise[:slug],
          title: exercise[:slug].titleize, # TODO: what to do with practice exercise names?
          prerequisites: find_concepts(exercise[:prerequisites]),
          deprecated: exercise[:deprecated] || false,
          git_sha: head_git_track.commit.oid,
          synced_to_git_sha: head_git_track.commit.oid
        )
      end
    end

    def track_needs_updating?
      track_config_modified?
    end

    def find_concepts(concept_slugs)
      concept_slugs.map { |concept_slug| ::Track::Concept.find_by!(slug: concept_slug) }
    end
  end
end
