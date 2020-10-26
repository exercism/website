module ViewComponents
  module Track
    class GenericNav < ViewComponent
      initialize_with :track, :klass, :elements

      def to_s
        tag.nav(class: klass) do
          tag.div(class: 'lg-container container') do
            safe_join([
              # link_to(
              #   graphical_icon("arrow-left"),
              #   Exercism::Routes.tracks_path,
              #   class: "back",
              #   'aria-label': "Back to all tracks"
              # ),
              image_tag(track.icon_url, class: 'c-track-icon'),
              tag.div(track.title, class: 'title')
            ] + elements)
          end
        end
      end
    end
  end
end
