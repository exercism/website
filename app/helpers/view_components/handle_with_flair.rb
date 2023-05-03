module ViewComponents
  class HandleWithFlair < ViewComponent
    include Mandate

    initialize_with :handle, :flair, size: :base

    def to_s
      tag.span(class: 'flex items-center') do
        safe_join(
          [
            tag.span(handle),
            icon_part
          ].compact
        )
      end
    end

    private
    def icon_part
      return unless flair.present?

      icon(
        icon_name,
        flair,
        style: "all:unset; height:#{size_in_px}; width:#{size_in_px};"
      )
    end

    def icon_name
      ICONS[flair.to_sym]
    end

    memoize
    def size_in_px
      "#{SIZES[size.to_sym]}px"
    end

    SIZES = {
      small: 10,
      base: 13,
      medium: 15,
      large: 17,
      xlarge: 28
    }.freeze

    ICONS = {
      original_insider: :original_insiders,
      insider: :insiders
    }.freeze
  end
end
