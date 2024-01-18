class GenericExercise < ApplicationRecord
  extend Mandate::Memoize

  enum status: { active: 0, deprecated: 1 }

  delegate :description_html, to: :git

  def status = super.to_sym

  memoize
  def git = Git::ProblemSpecifications::Exercise.new(slug)
end
