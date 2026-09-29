class SerializeExerciseApproachForSharing
  include Mandate

  initialize_with :approach

  def call
    {
      title: I18n.t("serializers.exercise_approach_for_sharing.title"),
      share_title: approach.title,
      share_link: Exercism::Routes.track_exercise_approach_url(approach.track, approach.exercise, approach)
    }
  end
end
