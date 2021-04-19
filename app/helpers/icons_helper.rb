module IconsHelper
  def graphical_icon(icon, css_class: nil, category: 'icons', hex: false)
    icon(icon, nil, role: :presentation, css_class: css_class, category: category, hex: hex)
  end

  def icon(icon, alt, role: nil, category: 'icons', css_class: nil, hex: false)
    return if icon.blank?

    if hex
      tag.div(class: "c-icon #{css_class} --hex") do
        image_pack_tag "#{category}/#{icon}.svg", role: role, alt: alt.to_s
      end
    else
      image_pack_tag "#{category}/#{icon}.svg",
        role: role,
        alt: alt.to_s,
        class: "c-icon #{css_class} #{'--hex' if hex}".strip
    end
  rescue StandardError => e
    raise e unless Rails.env.production?
  end

  def track_icon(track, css_class: nil)
    image_tag track.icon_url, alt: track.title,
                              class: "c-icon c-track-icon #{css_class} --#{track.slug}"
  end

  def exercise_icon(exercise, css_class: nil)
    error_icon = asset_pack_url("media/images/graphics/missing-exercise.svg")

    image_tag exercise.icon_url,
      alt: exercise.title,
      class: "c-icon c-exercise-icon #{css_class}",
      onerror: "if (this.src != '#{error_icon}') this.src = '#{error_icon}';"
  end
end
