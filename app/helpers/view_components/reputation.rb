module ViewComponents
  class Reputation < ViewComponent
    def initialize(reputation, flashy: false)
      super()

      @reputation = reputation
      @flashy = flashy
    end

    def to_s
      tag.div(class: css_class, 'aria-label': "#{reputation} reputation") do
        flashy ? tag.div(inner, class: "--inner") : inner
      end
    end

    private
    attr_reader :reputation, :flashy

    def css_class
      flashy ? "c-primary-reputation" : "c-reputation"
    end

    def inner
      icon(:reputation, "Reputation") + tag.span(reputation)
    end
  end
end
