class Localization::Original < ApplicationRecord
  disable_sti!

  ## Types
  # unknown
  # website_server_side
  # website_client_side
  # problem_specifications_introduction
  # problem_specifications_instructions
  # problem_specifications_description
  # exercise_introduction
  # exercise_instructions
  # exercise_description
  # concept_content
  # blog_post_content
  # docs_content

  has_many :translations, dependent: :destroy, foreign_key: :key, primary_key: :key, inverse_of: :original

  before_create do
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def to_param = uuid
  def type = super.to_sym
end
