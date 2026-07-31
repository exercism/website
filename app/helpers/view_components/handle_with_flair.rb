module ViewComponents
  class HandleWithFlair < ViewComponent
    include Mandate

    initialize_with :handle, :flair, size: :base

    def to_s
      content = safe_join([handle, icon_part].compact)
      tag.span(content, class: 'inline-flex items-center leading-150')
    end

    private
    def icon_part
      return unless flair.present?

      icon(
        icon_name,
        icon_alt,
        style: "all:unset; height: #{size_in_px}; width: #{size_in_px}; margin-left: #{ml_in_px}; margin-bottom: #{mb_in_px}",
        title: icon_title
      )
    end

    def icon_name
      ICONS[flair.to_sym]
    end

    def icon_alt
      I18n.t("components.handle_with_flair.icon_alt", title: icon_title)
    end

    memoize
    def icon_title
      I18n.t("components.handle_with_flair.titles.#{flair}")
    end

    memoize
    def size_in_px
      "#{SIZES[size.to_sym]}px"
    end

    memoize
    def ml_in_px
      "#{(SIZES[size.to_sym] / 4.0).ceil}px"
    end

    memoize
    def mb_in_px
      "#{(SIZES[size.to_sym] / 7.0).floor}px"
    end

    SIZES = {
      small: 10,
      base: 13,
      medium: 15,
      large: 17,
      xlarge: 28
    }.freeze

    ICONS = {
      insider: 'insiders',
      lifetime_insider: 'lifetime-insiders',
      founder: 'staff-flair',
      staff: 'staff-flair'
    }.freeze
  end
end
