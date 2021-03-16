module IconsHelper
  def graphical_icon(icon, css_class: nil, category: 'icons', hex: false)
    icon(icon, nil, role: :presentation, css_class: css_class, category: category, hex: hex)
  end

  def icon(icon, alt, role: 'img', category: 'icons', css_class: nil, hex: false)
    image_pack_tag "#{category}/#{icon}.svg",
      role: role,
      alt: alt,
      class: "c-icon #{css_class} #{'--hex' if hex}".strip
  end

  def track_icon(track, css_class: nil)
    icon track.icon_name,
      track.title,
      category: 'tracks',
      css_class: "c-track-icon #{css_class}"
  end

  def exercise_icon(exercise, css_class: nil)
    icon exercise.icon_name,
      exercise.title,
      category: 'exercises',
      css_class: "c-exercise-icon #{css_class}"
  end
end
