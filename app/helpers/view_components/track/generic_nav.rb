module ViewComponents
  module Track
    class GenericNav < ViewComponent
      initialize_with :view_context, :track, :klass, :elements

      def to_s
        tag.nav(class: klass) do
          tag.div(class: 'lg-container container') do
            safe_join([
              # TODO: We're probably getting rid of the back arrow
              # but I'm leaving this here in case we decide to keep
              # it. If it's still liek this at launch, remove it .
              #
              # link_to(
              #   graphical_icon("arrow-left"),
              #   Exercism::Routes.tracks_path,
              #   class: "back",
              #   'aria-label': "Back to all tracks"
              # ),
              track_icon(track),
              link_to(track.title, Exercism::Routes.track_path(track), class: 'title')
            ] + elements)
          end
        end
      end
    end
  end
end
