class Solution::Star < ApplicationRecord
  belongs_to :solution, counter_cache: :num_stars
  belongs_to :user
end
