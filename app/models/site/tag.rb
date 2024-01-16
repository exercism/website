class Site::Tag < ApplicationRecord
  extend Mandate::Memoize

  memoize
  def category = split_string.first

  memoize
  def name = split_string.second

  memoize
  def split_string = tag.split(':')
end
