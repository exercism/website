class Track::RetrieveForegonePracticeExercises
  include Mandate

  initialize_with :track

  def call
    GenericExercise.where(slug: track.git.foregone_exercises)
  rescue Git::MissingCommitError
    GenericExercise.none
  end
end
