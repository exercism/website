module IconsHelper
  def graphical_icon(icon, css_class: nil, category: 'icons', hex: false)
    icon(icon, nil, role: :presentation, css_class: css_class, category: category, hex: hex)
  end

  def icon(icon, alt, role: nil, category: 'icons', css_class: nil, hex: false)
    return if icon.blank?

    icon_class = "c-icon #{css_class} #{'--hex' if hex}".strip

    begin
      if hex
        tag.div(class: icon_class) do
          image_pack_tag "media/#{category}/#{icon}.svg", role: role, alt: alt.to_s
        end
      else
        image_pack_tag "media/#{category}/#{icon}.svg", role: role, alt: alt.to_s, class: icon_class
      end
    rescue Webpacker::Manifest::MissingEntryError
      missing_icon(alt: alt, icon_class: icon_class, role: role)
    end
  rescue StandardError => e
    raise e unless Rails.env.production?
  end

  def track_icon(track, css_class: nil)
    image_tag track.icon_url, alt: track.title,
                              class: "c-track-icon #{css_class} --#{track.slug}"

    # Use the code below to load the icon from webpack
    # image_pack_tag "media/tracks/#{track.slug}.svg",
    #   alt: track.title,
    #   class: "c-track-icon #{css_class} --#{track.slug}"
  end

  def exercise_icon(exercise, css_class: nil)
    error_icon = asset_pack_url("media/graphics/missing-exercise.svg")

    image_tag exercise.icon_url,
      alt: exercise.title,
      class: "c-icon c-exercise-icon #{css_class}",
      onerror: "if (this.src != '#{error_icon}') this.src = '#{error_icon}';"

    # Use the code below to load the icon from webpack
    # image_pack_tag "media/exercises/#{exercise.icon_name}.svg",
    #   alt: exercise.title,
    #   class: "c-icon c-exercise-icon #{css_class}",
    #   onerror: "if (this.src != '#{error_icon}') this.src = '#{error_icon}';"
  rescue Webpacker::Manifest::MissingEntryError
    missing_icon(alt: exercise.title, icon_class: "c-icon c-exercise-icon #{css_class}")
  end

  def missing_icon(alt:, icon_class:, role: nil)
    image_pack_tag "media/images/missing.svg", role: role, alt: alt.to_s, class: icon_class
  end
end
