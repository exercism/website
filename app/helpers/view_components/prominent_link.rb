module ViewComponents
  class ProminentLink < ViewComponent
    def initialize(text, url, with_bg: false, external: false)
      @text = text
      @url = url
      @with_bg = with_bg
      @external = external

      super
    end

    def to_s
      send(link_method, url, class: css_class) do
        tag.span(text) +
          graphical_icon("arrow-right")
      end
    end

    private
    attr_reader :text, :url, :with_bg, :external

    def link_method
      external ? :external_link_to : :link_to
    end

    def css_class
      c = ['c-prominent-link']
      c << '--with-bg' if with_bg
      c.join(" ")
    end
  end
end
