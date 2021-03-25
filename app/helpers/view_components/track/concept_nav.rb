module ViewComponents
  module Track
    class ConceptNav < ViewComponent
      initialize_with :track

      def to_s
        tag.nav(class: "c-track-concept-nav") do
          tag.div(class: 'lg-container container') do
            safe_join(
              [
                track_icon(track),
                link_to(track.title, Exercism::Routes.track_path(track), class: 'title'),
                tag.div("/", class: 'divider'),
                link_to("Concepts", Exercism::Routes.track_concepts_path(track), class: 'item')
              ]
            )
          end
        end
      end
    end
  end
end
