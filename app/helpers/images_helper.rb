module ImagesHelper
  def bg_img(src, alt, css_class: 'c-bg-img', extra_css_class: nil)
    tag.div(
      class: [css_class, extra_css_class].compact.join(" "),
      style: "background-image:url(\"#{src}\")"
    ) do
      image_tag(src, alt: alt.to_s, class: "sr-only")
    end
  end

  def avatar(user, alt: nil, css_class: 'c-avatar', extra_css_class: nil)
    bg_img(
      user.avatar_url,
      (alt || "Uploaded avatar of #{user.handle}"),
      css_class:,
      extra_css_class:
    )
  end

  def avatar_link(user, css_class: nil, **kwargs)
    link_to(
      profile_path(user),
      kwargs.merge(
        class: ['c-avatar', css_class].compact.join(" "),
        style: "background-image:url(\"#{user.avatar_url}\")",
        "aria-title": "Link to #{user.handle}'s profile"
      )
    ) do
      image_tag(user.avatar_url, alt: "Uploaded avatar of #{user.handle}", class: "sr-only")
    end
  end

  def key_feature_icon_url(feature)
    "#{Exercism.config.website_icons_host}/key-features/#{feature}.svg"
  end
end
