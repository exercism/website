class Exercise::Tag < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :exercise

  memoize
  def category = tag.split(':').first

  memoize
  def name = tag.split(':').second

  memoize
  def to_s = "#{category.titleize}: #{name.titleize}"
end
