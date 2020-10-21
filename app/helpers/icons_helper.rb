module IconsHelper
  def graphical_icon(icon)
    icon(icon, nil)
  end

  def icon(icon, alt)
    tag.svg(role: "img") do
      parts = [
        (alt ? tag.title(alt) : nil),
        tag(:use, "xlink:href": "##{icon}")
      ]
      safe_join(parts)
    end
  end
end
