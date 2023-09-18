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

  # Use as follows:
  # srcset_tag "screenshots/landing-page-exercise.webp", [400, 688, 800, 1376], [[:lg, "50vw"], "100vw"]
  def srcset_tag(base_src, image_sizes, page_sizes, **kwargs)
    filepath, ext = base_src.split(".")
    kwargs[:srcset] = image_sizes.map do |size|
      "#{asset_url("#{filepath}-#{size}w.#{ext}")} #{size}w"
    end.join(", ")

    size_mappings = { sm: 640, md: 768, lg: 1024, xl: 1280 }
    kwargs[:sizes] = Array(page_sizes).map do |pair|
      if pair.is_a?(Array)
        "(min-width: #{size_mappings[pair[0].to_sym]}px) #{pair[1]}"
      else
        pair
      end
    end.join(", ")

    src = "#{filepath}-#{image_sizes.last}w.#{ext}"
    image_tag(src, **kwargs)
  end
end
