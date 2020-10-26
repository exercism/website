module ImagesHelper
  def bg_img(src, alt, css_class: 'c-bg-img', extra_css_class: nil)
    tag.div(
      class: [css_class, extra_css_class].compact.join(" "),
      style: "background-image:url(#{src})"
    ) do
      image_tag(src, alt: alt, class: "tw-sr-only")
    end
  end

  def rounded_bg_img(src, alt, css_class: 'c-rounded-bg-img', extra_css_class: nil)
    bg_img(src, alt, css_class: css_class, extra_css_class: extra_css_class)
  end

  def rounded_bg_link(src, href, title, alt, css_class)
    link_to(
      href,
      class: ['c-rounded-bg-img', css_class].compact.join(" "),
      style: "background-image:url(#{src})",
      "aria-title": title
    ) do
      image_tag(src, alt: alt, class: "tw-sr-only")
    end
  end
end
