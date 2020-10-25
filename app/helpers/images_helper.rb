module ImagesHelper
  def bg_img(src, alt: nil, css_class: 'c-bg-img', extra_css_class: nil)
    tag.div("", alt: alt,
                role: "img",
                class: [css_class, extra_css_class].compact.join(" "),
                style: "background-image:url(#{src})")
  end

  def rounded_bg_img(src, alt: nil, css_class: 'c-rounded-bg-img', extra_css_class: nil)
    bg_img(src, alt: alt, css_class: css_class, extra_css_class: extra_css_class)
  end

  def rounded_bg_link(src, href, alt, css_class)
    link_to(
      "",
      href,
      alt: alt,
      class: ['c-rounded-bg-img', css_class].compact.join(" "),
      style: "background-image:url(#{src})"
    )
  end
end
