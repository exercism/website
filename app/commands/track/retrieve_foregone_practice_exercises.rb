class Track::RetrieveForegonePracticeExercises
  include Mandate

  initialize_with :track

  def call = GenericExercise.where(slug: track.git.foregone_exercises)
end
