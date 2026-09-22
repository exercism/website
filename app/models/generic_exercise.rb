class GenericExercise < ApplicationRecord
  extend Mandate::Memoize
  include HasTranslatedMetadata

  enum status: { active: 0, deprecated: 1 }

  delegate :description_html, to: :git

  def status = super.to_sym

  def title = translated_metadata("exercise:#{slug}:title", super)
  def blurb = translated_metadata("exercise:#{slug}:blurb", super)
  def source = translated_metadata("exercise:#{slug}:source", super)
  def deep_dive_blurb = translated_metadata("exercise:#{slug}:deep_dive_blurb", super)

  def translation_metadata_repo_name = "problem-specifications"

  memoize
  def git = Git::ProblemSpecifications::Exercise.new(slug)

  def url = "https://github.com/exercism/problem-specifications/tree/main/exercises/#{slug}"
  def icon_url = Icons::DetermineUrlFor.("exercises/#{slug}.svg", Icons::DetermineUrlFor::MISSING_EXERCISE_ICON)

  def self.for!(slug) = find_by!(slug:)

  def self.for(slug)
    for!(slug)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
