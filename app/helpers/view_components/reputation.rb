module ViewComponents
  class Reputation < ViewComponent
    def initialize(reputation, size: nil, flashy: false)
      super()

      @reputation = reputation
      @size = size
      @flashy = flashy
    end

    def to_s
      css_classes = []
      css_classes << (flashy ? "c-primary-reputation" : "c-reputation")
      css_classes << "--#{size}" if size

      tag.div(inner, class: css_classes.join(" "), 'aria-label': I18n.t("components.reputation.aria_label", reputation:))
    end

    private
    attr_reader :reputation, :size, :flashy

    def inner
      icon(:reputation, I18n.t("components.reputation.icon_alt")) + tag.span(reputation)
    end
  end
end
