class Solution::MentorRequest < ApplicationRecord
  disable_sti!

  enum status: [:pending, :fulfilled]
  enum type: [:code_review, :question], _prefix: true

  belongs_to :solution
  belongs_to :locked_by, class_name: "User", optional: true

  def status
    super.to_sym
  end

  def type
    super.to_sym
  end

  def fulfilled!
    update_column(:status, :fulfilled)
  end

  # If this request is locked by someone else then
  # the user has timed out and someone else has started 
  # work on this solution, which is a mess.
  #
  # If the solution isn't locked at all then the person timed
  # out but no-one else claimed it so let's carry on
  def lockable_by?(mentor)
    !locked? || locked_by == mentor
  end

  def locked?
    locked_until.present? && Time.current < locked_until
  end
end
