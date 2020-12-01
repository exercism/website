module Git
  class SyncExercise < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    private
    attr_reader :exercise

    def sync!
      # # TODO: validate exercise to prevent invalid exercise data
      send("sync_#{exercise.git_type}_exercise!")
    end

    def sync_concept_exercise!
      return exercise.update!(synced_to_git_sha: head_git_exercise.commit.oid) unless exercise_needs_updating?

      # TODO: verify if exercise concepts are also in the track concepts first
      taught_concepts = config_exercise[:concepts].map do |concept_slug|
        config_concept = find_config_concept(concept_slug)
        ::Track::Concept.create_or_find_by!(uuid: config_concept[:uuid]) do |c|
          c.slug = config_concept[:slug]
          c.name = config_concept[:name]
          c.blurb = config_concept[:blurb]
          c.synced_to_git_sha = head_git_exercise.commit.oid
          c.track = exercise.track
        end
      end
      exercise.taught_concepts.replace(taught_concepts)

      exercise.update!(
        slug: config_exercise[:slug],
        title: config_exercise[:name],
        deprecated: config_exercise[:deprecated] || false,
        git_sha: head_git_exercise.commit.oid,
        synced_to_git_sha: head_git_exercise.commit.oid
      )
    end

    def sync_practice_exercise!
      # TODO
    end

    def exercise_needs_updating?
      config_exercise_modified? || exercise_files_modified?
    end

    def config_exercise_modified?
      return false unless track_config_modified?

      config_exercise[:slug] != exercise.slug ||
        config_exercise[:name] != exercise.title ||
        !!config_exercise[:deprecated] != exercise.deprecated ||
        config_exercise[:concepts].sort != exercise.taught_concepts.map(&:slug).sort
    end

    def exercise_files_modified?
      head_git_exercise.non_ignored_absolute_filepaths.any? { |filepath| filepath_in_diff?(filepath) }
    end

    def find_config_concept(slug)
      config_concepts.find { |e| e[:slug] == slug }
    end

    memoize
    def config_exercise
      # TODO: determine what to do when the exercise could not be found
      head_git_track.config[:exercises][:concept].find { |e| e[:uuid] == exercise.uuid }
    end

    memoize
    def config_concepts
      head_git_track.config[:concepts]
    end

    memoize
    def head_git_exercise
      Git::Exercise.new(exercise.track.slug, exercise.slug, exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
