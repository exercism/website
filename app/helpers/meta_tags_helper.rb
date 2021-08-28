module MetaTagsHelper
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

  def track_meta_tags(track)
    content_for :meta_title, "#{track.title} on Exercism"
    content_for :meta_description,
      "Get fluent in #{track.title} by solving #{track.num_exercises} exercises. And then level up with mentoring from our world-class team." # rubocop:disable Layout/LineLength
  end

  def concept_meta_tags(concept, user_track)
    content_for :meta_title, "#{concept.name} in #{user_track.track.title} on Exercism"
    content_for :meta_description,
      "Master #{concept.name} in #{user_track.track.title} by solving #{user_track.num_exercises_for_concept(concept)} exercises, with support from our world-class team." # rubocop:disable Layout/LineLength
  end

  def exercise_meta_tags(exercise, user_track)
    content_for :meta_title, "#{exercise.title} in #{user_track.track.title} on Exercism"
    content_for :meta_description,
      "Can you solve #{exercise.title} in #{user_track.track.title}? Improve your #{user_track.track.title} skills with support from our world-class team of mentors." # rubocop:disable Layout/LineLength
  end
end
