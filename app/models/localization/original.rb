class Localization::Original < ApplicationRecord
  disable_sti!

  ## Types
  # name | prompt done | creation done
  # unknown
  # website_server_side ❌ ❌
  # website_client_side ❌ ❌
  # generic_exercise_introduction ✅ ✅
  # generic_exercise_instructions ✅ ✅
  # generic_exercise_title ✅ ✅
  # generic_exercise_blurb ✅ ✅
  # generic_exercise_source ✅ ✅
  # exercise_introduction ✅ ✅
  # exercise_instructions ✅ ✅
  # exercise_title  ✅ ✅
  # exercise_blurb  ✅ ✅
  # exercise_source  ✅ ✅
  # concept_name ❌ ✅
  # concept_blurb ❌ ✅
  # concept_introduction ❌ ✅
  # concept_about ❌ ✅
  # blog_post_content ❌ ❌
  # docs_content ❌ ❌

  has_many :translations, dependent: :destroy, foreign_key: :key, primary_key: :key, inverse_of: :original
  belongs_to :about, polymorphic: true, optional: true

  before_create do
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def to_param = uuid
  def type = super.to_sym

  def title
    if type.to_s.starts_with?("exercise_")
      "#{about.track.title} / #{about.title}"
    elsif type.to_s.starts_with?("concept_")
      "#{about.track.title} / #{about.title}"
    elsif type.to_s.starts_with?("generic_exericse_")
      "#{about.title} (Generic)"
    else
      type.to_s.humanize
    end
  end

  def usage_details
    return super if super.present?

    case type
    when :exercise_introduction
      "This is the introduction text shown on the exercise page. It sets the context of the STORY of the exercise. The instructions are shown next and are translated seperately." # rubocop:disable Layout/LineLength
    when :exercise_instructions
      "These are the instructions shown on the exercise page. They tell the user what to do to complete the exercise. The introduction is shown before and is translated seperately." # rubocop:disable Layout/LineLength
    when :exercise_title
      "This is the title of the exercise shown around the site in various places."
    when :exercise_blurb
      "This is a short blurb about the exercise, shown as part of an exercise widget (e.g. on the page that lists the exercises for a track)." # rubocop:disable Layout/LineLength
    when :exercise_source
      "This appears at the bottom of an exercise to show where it originated, and is included in the README downloaded via the CLI."
    when :generic_exercise_introduction
      "This is the **programming-language-agnostic** introduction text. Some tracks override it, but it's generally used across most languages. The instructions and an optional append come seperately." # rubocop:disable Layout/LineLength
    when :generic_exercise_instructions
      "These are the **programming-language-agnostic** instructions. Some tracks override them, but they're generally used across most languages. The introduction and an optional append come seperately." # rubocop:disable Layout/LineLength
    when :generic_exercise_title
      "This is the **programming-language-agnostic** title of the exercise. It can be overriden by tracks but almost never is."
    when :generic_exercise_blurb
      "This is a **programming-language-agnostic** short blurb about the exercise, shown as part of an exercise widget (e.g. on the page that lists the exercises for a track). It can be overriden by tracks but almost never is." # rubocop:disable Layout/LineLength
    when :generic_exercise_source
      "This appears at the bottom of an exercise to show where it originated, and is included in the README downloaded via the CLI. This is the **programming-language-agnostic** version, which can be overriden by tracks but almost never is." # rubocop:disable Layout/LineLength
    when :concept_name
      "This is the name of a programming concept for a specific track. It appears throughout the track".
        when :concept_blurb
      "This is a short blurb about a programming concept for a specific track. It appears on the concept page and in various places around the site." # rubocop:disable Layout/LineLength
    when :concept_introduction
      "This is the version of the concept explanation that is shown to students BEFORE they complete the associated exercise."
    when :concept_about
      "This is the version of the concept explanation that is shown to students AFTER they complete the associated exercise."
    when :blog_post_content
      "This is the content of a blog post shown on the blog."
    when :docs_content
      "This is the content of a documentation page shown on the docs."
    else
      "No usage details available."
    end
  end
end
