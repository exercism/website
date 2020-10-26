module ViewComponents
  module Track
    class ExercisesNav < ViewComponent
      initialize_with :track

      def to_s
        GenericNav.new(
          track,
          "c-track-exercises-nav",
          [
            tag.div("/", class: 'divider'),
            link_to("Exercises", Exercism::Routes.track_exercises_path(track), class: 'item')
          ]
        ).to_s
      end
    end
  end
end
