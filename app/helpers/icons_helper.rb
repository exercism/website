module IconsHelper
  def graphical_icon(icon, css_class: nil)
    icon(icon, nil, role: :presentation, css_class: css_class)
  end

  def icon(icon, alt, role: 'img', css_class: nil)
    tag.svg(role: role, class: "c-icon #{css_class}") do
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
    # TODO: Change to real icons
    suffix = exercise.title[0].ord < 78 ? "butterflies" : "rocket"
    graphical_icon("sample-exercise-#{suffix}", css_class: css_class)
  end
end
