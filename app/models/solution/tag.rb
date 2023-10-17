class Solution::Tag < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :solution
  belongs_to :exercise
  belongs_to :user

  before_validation on: :create do
    self.exercise = solution.exercise unless exercise
    self.user = solution.user unless user
  end

  memoize
  def category = tag.split(':').first

  memoize
  def name = tag.split(':').second

  memoize
  def to_s = "#{category.titleize}: #{name.titleize}"
end
