class Git::SyncProblemSpecifications
  include Mandate

  queue_as :default

  def call
    repo.update!

    repo.exercises.each do |exercise|
      GenericExercise::CreateOrUpdate.(exercise)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  memoize
  def repo = Git::ProblemSpecifications.new
end
