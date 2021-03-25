module ViewComponents
  module Track
    class GenericNav < ViewComponent
      initialize_with :view_context, :track, :klass, :elements

      def to_s
        tag.nav(class: klass) do
          tag.div(class: 'lg-container container') do
            safe_join([
              track_icon(track),
              link_to(track.title, Exercism::Routes.track_path(track), class: 'title')
            ] + elements)
          end
        end
      end
    end
  end
end
