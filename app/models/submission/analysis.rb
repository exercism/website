class Submission::Analysis < ApplicationRecord
  belongs_to :submission

  scope :ops_successful, -> { where(ops_status: 200) }

  def has_feedback?
    comments.present?
  end

  def comments
    data[:comments]
  end

  def ops_success?
    ops_status == 200
  end

  def ops_errored?
    !ops_success?
  end

  private
  # TODO: Memoize
  def data
    HashWithIndifferentAccess.new(super)
  end
end
