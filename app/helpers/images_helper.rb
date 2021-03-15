module ImagesHelper
  def bg_img(src, alt, css_class: 'c-bg-img', extra_css_class: nil)
    tag.div(
      class: [css_class, extra_css_class].compact.join(" "),
      style: "background-image:url(#{src})"
    ) do
      image_tag(src, alt: alt, class: "tw-sr-only")
    end
  end

  def avatar(user, alt: nil, css_class: 'c-avatar', extra_css_class: nil)
    bg_img(
      user.avatar_url,
      (alt || "Uploaded avatar of #{user.handle}"),
      css_class: css_class,
      extra_css_class: extra_css_class
    )
  end

  def rounded_bg_link(src, href, title, alt, css_class)
    link_to(
      href,
      class: ['c-avatar', css_class].compact.join(" "),
      style: "background-image:url(#{src})",
      "aria-title": title
    ) do
      image_tag(src, alt: alt, class: "tw-sr-only")
    end
  end
end
