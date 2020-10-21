module IconsHelper
  def icon(icon, alt)
    tag.svg(role: "img") do
      tag.title(alt) +
        tag(:use, "xlink:href": "##{icon}")
    end
  end
end
