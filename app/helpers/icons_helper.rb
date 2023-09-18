module IconsHelper
  def graphical_icon(icon, style: nil, css_class: nil, category: 'icons', hex: false, width: nil, height: nil)
    icon(icon, '', style:, css_class:, category:, hex:, width:, height:)
  end

  def icon(icon, alt, role: nil, category: 'icons', style: nil, css_class: nil, hex: false, height: nil, width: nil, title: nil)
    return if icon.blank?

    if hex
      tag.div(class: "c-icon #{css_class} --hex") do
        image_tag "#{category}/#{icon}.svg", role:, alt: alt.to_s, height:, width:
      end
    else
      image_tag "#{category}/#{icon}.svg",
        role:,
        alt: alt.to_s,
        class: "c-icon #{css_class} #{'--hex' if hex}".strip,
        height:, width:, style:, title:
    end
  rescue StandardError => e
    raise e unless Rails.env.production?
  end

  def track_icon(track, css_class: nil)
    error_icon = image_path("graphics/missing-track.svg")

    image_tag track.icon_url,
      alt: track.title,
      class: "c-track-icon #{css_class} --#{track.slug}",
      onerror: "if (this.src != '#{error_icon}') this.src = '#{error_icon}';"
  end

  def exercise_icon(exercise, css_class: nil)
    error_icon = image_path("graphics/missing-exercise.svg")

    image_tag exercise.icon_url,
      alt: exercise.title,
      class: "c-icon c-exercise-icon #{css_class}",
      onerror: "if (this.src != '#{error_icon}') this.src = '#{error_icon}';"
  end
end
