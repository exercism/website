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
    content_for?(:meta_description) ? content_for(:meta_description) :
      "Learn, practice and get world-class mentoring in over 50 languages. 100% free."
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
    return {} unless canonical_url.present? && locale_scoped_route? && !noindex_locale?

    Locale::Alternates.(canonical_url)
  end

  def noindex_locale? = !LocaleRoster.production?(I18n.locale)

  def frontend_catalog_url = TranslationRepo.frontend_catalog_url(I18n.locale)

  def html_lang = LocaleRoster.default?(I18n.locale) ? "en-US" : I18n.locale.to_s
  def html_dir = LocaleRoster.direction(I18n.locale)

  def track_meta_tags(user_track)
    content_for :meta_title, "#{user_track.track_title} on Exercism"
    content_for :meta_description,
      "Get fluent in #{user_track.track_title} by solving #{user_track.num_exercises} exercises. And then level up with mentoring from our world-class team." # rubocop:disable Layout/LineLength
    content_for :canonical_url, track_url(user_track.track)
  end

  def concept_meta_tags(concept, user_track)
    content_for :meta_title, "#{concept.name} in #{user_track.track_title} on Exercism"
    content_for :meta_description,
      "Master #{concept.name} in #{user_track.track_title} by solving #{user_track.num_exercises_for_concept(concept)} exercises, with support from our world-class team." # rubocop:disable Layout/LineLength
    content_for :canonical_url, track_concept_url(user_track.track, concept)
  end

  def exercise_meta_tags(exercise, user_track)
    content_for :meta_title, "#{exercise.title} in #{user_track.track_title} on Exercism"
    content_for :meta_description,
      "Can you solve #{exercise.title} in #{user_track.track_title}? Improve your #{user_track.track_title} skills with support from our world-class team of mentors." # rubocop:disable Layout/LineLength
    content_for :canonical_url, track_exercise_url(user_track.track, exercise)
  end
end
