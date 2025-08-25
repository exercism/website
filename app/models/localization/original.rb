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

  before_create do
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def to_param = uuid
  def type = super.to_sym
end
