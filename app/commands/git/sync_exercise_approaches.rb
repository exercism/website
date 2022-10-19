module Git
  class SyncExerciseApproaches < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    def call
      exercise.update(approaches:)
      Git::SyncExerciseApproachIntroduction.(exercise, introduction_config)
      ::Exercise::UpdateHasApproaches.(exercise)
    end

    private
    attr_reader :exercise

    def approaches = approaches_config.map { |approach| Git::SyncExerciseApproach.(exercise, approach) }

    def introduction_config = head_git_approaches.config_introduction

    memoize
    def approaches_config = head_git_approaches.approaches.to_a

    memoize
    def head_git_approaches = head_git_exercise.approaches

    memoize
    def head_git_exercise
      exercise_config = head_git_track.find_exercise(exercise.uuid)
      Git::Exercise.new(exercise_config[:slug], exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
