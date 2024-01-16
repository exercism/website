class Solution::Tag < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :solution
  belongs_to :exercise
  belongs_to :track
  belongs_to :user

  before_validation on: :create do
    self.exercise_id = solution.exercise_id unless exercise_id
    self.track_id = exercise.track_id unless track_id
    self.user_id = solution.user_id unless user_id
  end

  memoize
  def category = tag.split(':').first

  memoize
  def name = tag.split(':').second

  memoize
  def to_s = "#{category.titleize}: #{name.titleize}"
end
