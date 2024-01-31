class Git::SyncProblemSpecifications
  include Mandate

  queue_as :default

  def call
    repo.update!

    repo.exercises.each do |exercise|
      GenericExercise::CreateOrUpdate.(
        exercise.slug, exercise.title, exercise.blurb,
        exercise.source, exercise.source_url,
        exercise.deep_dive_youtube_id, exercise.deep_dive_blurb,
        exercise.deprecated? ? :deprecated : :active
      )
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  memoize
  def repo = Git::ProblemSpecifications.new
end
