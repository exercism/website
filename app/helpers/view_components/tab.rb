module ViewComponents
  class Tab < ViewComponent
    extend Mandate::Memoize

    initialize_with :text, :icon, :href, :selected

    def to_s
      link_to href, class: "c-tab #{'selected' if selected}" do
        graphical_icon(icon) +
          tag.span(text, data: { text: })
      end
    end
  end
end
