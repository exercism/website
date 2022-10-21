class SerializeExerciseApproachForSharing
  include Mandate

  initialize_with :approach

  def call
    {
      title: "Share this approach",
      share_title: approach.title,
      share_link: Exercism::Routes.track_exercise_approach_url(approach.track, approach.exercise, approach)
    }
  end
end
