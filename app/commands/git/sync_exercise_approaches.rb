class Git::SyncExerciseApproaches < Git::Sync
  include Mandate

  def initialize(exercise)
    super(exercise.track, exercise.synced_to_git_sha)
    @exercise = exercise
  end

  def call
    fingerprint_before = approaches_fingerprint

    # This removes any approaches that aren't read from the config below
    exercise.update(approaches:)
    Git::SyncExerciseApproachIntroduction.(exercise, introduction_config)

    # A force-sync runs this for every exercise on every track, so only purge
    # when the approaches genuinely changed. Otherwise the weekly SyncTracksJob
    # would burst past Cloudflare's per-zone purge rate limits.
    ::Exercise::InvalidateCloudflareCache.defer(exercise) if approaches_fingerprint != fingerprint_before
  end

  private
  attr_reader :exercise

  # updated_at only moves when an approach's content actually changes, so
  # this catches edits as well as additions and removals.
  def approaches_fingerprint = exercise.approaches.reload.pluck(:id, :updated_at).sort

  def approaches
    approaches_config.map.with_index do |approach, index|
      Git::SyncExerciseApproach.(exercise, approach, index + 1)
    end
  end

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
