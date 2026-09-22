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
    content_for(:canonical_url).presence
  end

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
