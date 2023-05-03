module ViewComponents
  class HandleWithFlair < ViewComponent
    def initialize(handle, flair, size: 'base')
      @handle = handle
      @flair = flair
      size_value = map_size_to_value(size)
      @height = "#{size_value}px"
      @width = "#{size_value}px"

      super()
    end

    def icon
      return unless @flair.present?

      icon_name = @flair == "original_insider" ? :original_insiders : :insiders
      icon_styles = "all:unset; height:#{@height}; width:#{@width};"
      graphical_icon(icon_name, style: icon_styles).to_s
    end

    def to_s
      tag.span(
        class: 'flex items-center',
        title: @flair
      ) do
        content = @handle
        content += "&nbsp;#{icon}" if @flair.present?
        content.html_safe
      end
    end

    private
    def map_size_to_value(size_variant)
      size_mapping = {
        'xsmall' => 10,
        'small' => 13,
        'base' => 15,
        'large' => 17,
        'xlarge' => 28
      }
      size_mapping[size_variant.to_s] || size_mapping['base']
    end
  end
end
