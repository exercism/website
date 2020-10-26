module IconsHelper
  def graphical_icon(icon)
    icon(icon, nil, role: :presentation)
  end

  def icon(icon, alt, role: 'img')
    tag.svg(role: role) do
      parts = [
        (alt ? tag.title(alt) : nil),
        tag(:use, "xlink:href": "##{icon}")
      ]
      safe_join(parts)
    end
  end

  def track_icon(track)
    # TODO: Change to use icon
    image_tag(track.icon_url, alt: track.title, class: 'c-track-icon')
  end
end
