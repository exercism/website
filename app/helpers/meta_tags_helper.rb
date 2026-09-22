module MetaTagsHelper
  def require_stylesheet(stylesheet)
    content_for :stylesheets do
      stylesheet_link_tag stylesheet, "data-turbo-track": "reload"
    end
  end

  def meta_title
    content_for?(:meta_title) ? content_for(:meta_title) : "Exercism"
  end

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : I18n.t("helpers.meta_tags.default_description")
  end

  def meta_image_url
    content_for?(:meta_image) ? content_for(:meta_image) :
    "#{Exercism.config.website_icons_host}/meta/og.png"
  end

  def meta_url
    content_for?(:meta_url) ? content_for(:meta_url) : request.original_url.gsub(%r{/$}, "")
  end

  def canonical_url
    if content_for?(:canonical_url)
      url = content_for(:canonical_url)
    else
      return unless locale_scoped_route?

      url = "#{request.base_url}#{request.path}"
    end

    locale_scoped_route? ? Locale::SwapInUrl.(url, I18n.locale) : url
  end

  def hreflang_alternates
    return {} unless canonical_url.present? && locale_scoped_route?

    Locale::Alternates.(canonical_url)
  end

  # The banner offering a visitor their own language is built client-side, so
  # every served locale's copy, name and path ships with the page. It varies by
  # URL alone, which is what keeps the page cacheable.
  def locale_banner_data
    return nil if I18n.available_locales.one?

    page_name = Locale::Name.(I18n.locale).native

    I18n.available_locales.index_with do |locale|
      native = Locale::Name.(locale).native

      I18n.with_locale(locale) do
        {
          name: native,
          dir: Locale::Direction.(locale),
          path: path_for_locale(locale),
          pre: I18n.t("components.locale_banner.pre", current: page_name),
          link: I18n.t("components.locale_banner.link", offered: native),
          dismiss: I18n.t("components.locale_banner.dismiss")
        }
      end
    end.to_json
  end

  def frontend_catalog_url = TranslationRepo.frontend_catalog_url(I18n.locale)

  def html_lang = I18n.locale == I18n.default_locale ? "en-US" : I18n.locale.to_s
  def html_dir = Locale::Direction.(I18n.locale)

  def track_meta_tags(user_track)
    content_for :meta_title, I18n.t("helpers.meta_tags.track.title", track_title: user_track.track_title)
    content_for :meta_description, I18n.t("helpers.meta_tags.track.description",
      track_title: user_track.track_title, num_exercises: user_track.num_exercises)
    content_for :canonical_url, track_url(user_track.track)
  end

  def concept_meta_tags(concept, user_track)
    content_for :meta_title, I18n.t("helpers.meta_tags.concept.title",
      concept_name: concept.name, track_title: user_track.track_title)
    content_for :meta_description, I18n.t("helpers.meta_tags.concept.description",
      concept_name: concept.name, track_title: user_track.track_title,
      num_exercises: user_track.num_exercises_for_concept(concept))
    content_for :canonical_url, track_concept_url(user_track.track, concept)
  end

  def exercise_meta_tags(exercise, user_track)
    content_for :meta_title, I18n.t("helpers.meta_tags.exercise.title",
      exercise_title: exercise.title, track_title: user_track.track_title)
    content_for :meta_description, I18n.t("helpers.meta_tags.exercise.description",
      exercise_title: exercise.title, track_title: user_track.track_title)
    content_for :canonical_url, track_exercise_url(user_track.track, exercise)
  end
end
