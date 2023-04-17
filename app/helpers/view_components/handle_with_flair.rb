module ViewComponents
  class HandleWithFlair < ViewComponent
    def initialize(handle, flair, size: nil)
      @handle = handle
      @flair = flair
      @height = size
      @width = size

      super()
    end

    def icon
      return unless @flair.present?

      icon_name = @flair == "original_insider" ? :og_insiders : :insiders
      icon_styles = "all:unset; height:#{@height}; width:#{@width};"
      graphical_icon(icon_name, style: icon_styles).to_s
    end

    def to_s
      tag.span(class: 'flex items-center', title: @flair) do
        "#{@handle}&nbsp;#{icon}".html_safe
      end
    end
  end
end
