class Solution::MentorRequest < ApplicationRecord
  disable_sti!

  enum status: [:pending, :fulfilled]
  enum type: [:code_review, :question], _prefix: true

  belongs_to :solution

  def status
    super.to_sym
  end

  def fulfilled!
    update_column(:status, :fulfilled)
  end
end
