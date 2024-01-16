class Exercise::Tag < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :exercise

  scope :filterable, -> { where(filterable: true) }

  memoize
  def category = split_string.first

  memoize
  def name = split_string.second

  memoize
  def to_s = "#{category.titleize}: #{name.titleize}"

  memoize
  def split_string
    tag.split(':')
  end
end
