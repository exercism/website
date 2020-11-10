module ViewComponents
  class ProminentLink < ViewComponent
    initialize_with :text, :url

    def to_s
      link_to(url, class: 'c-prominent-link') do
        tag.span(text) +
          graphical_icon("arrow-right")
      end
    end
  end
end
