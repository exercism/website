module IconsHelper
  def graphical_icon(icon, css_class: nil, hex: false)
    icon(icon, nil, role: :presentation, css_class: css_class, hex: hex)
  end

  def icon(icon, alt, role: 'img', css_class: nil, hex: false)
    classes = "c-icon #{css_class} #{'--hex' if hex}".strip
    tag.svg(role: role, class: classes) do
      parts = [
        (alt ? tag.title(alt) : nil),
        tag(:use, "xlink:href": "##{icon}")
      ]
      safe_join(parts)
    end
  end

  def track_icon(track)
    # TODO: Change to real icons
    icon("sample-track", track.title, css_class: 'c-track-icon')
  end

  def exercise_icon(exercise, css_class: nil)
    graphical_icon(exercise.icon_name, css_class: "c-exercise-icon #{css_class}")
  end
end
