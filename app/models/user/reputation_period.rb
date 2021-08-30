class User::ReputationPeriod < ApplicationRecord
  enum period: { forever: 0, year: 1, month: 2, week: 3 }
  enum about: { everything: 0, track: 1 }, _prefix: true
  enum category: { any: 0, building: 1, maintaining: 2, authoring: 3, mentoring: 4 }, _suffix: true

  scope :dirty, -> { where(dirty: true) }
  belongs_to :user

  before_save do
    self.user_handle = user.handle if user_handle.blank?
  end
end

# This takes 10s per thing with 1.6m records

# [0, 1, 2, 3].each do |period|
#   [0, 1, 2, 3, 4, 5].each do |category|
#     [0, 1].each do |about|
#       ["NULL", *(0..5)].each do |about_id|
#         ActiveRecord::Base.connection.execute("
#           INSERT INTO user_reputation_periods
#           (user_id, period, about, category, about_id, reputation)
#           SELECT urt.user_id, #{period}, #{about}, #{category}, #{about_id}, SUM(urt.value)
#           FROM user_reputation_tokens urt
#           GROUP BY user_id
#         ")
#       end
#     end
#   end
# end

# User::ReputationPeriod.order(reputation: :desc).select(:user_id).page(1).per(20).to_a
