class GenericExercise < ApplicationRecord
  extend Mandate::Memoize

  enum status: { active: 0, deprecated: 1 }

  delegate :description_html, to: :git

  def status = super.to_sym

  memoize
  def git = Git::ProblemSpecifications::Exercise.new(slug)

  def url = "https://github.com/exercism/problem-specifications/tree/main/exercises/#{slug}"
  def icon_url = "#{Exercism.config.website_icons_host}/exercises/#{slug}.svg"

  def self.for!(slug) = find_by!(slug:)

  def self.for(slug)
    for!(slug)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
