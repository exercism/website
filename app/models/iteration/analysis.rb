class Iteration::Analysis < ApplicationRecord
  belongs_to :iteration

  scope :ops_successful, -> { where(ops_status: 200) }

  def status
    data[:status].try(&:to_sym)
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

  def approved?
    status == :approve
  end

  def disapproved?
    status == :disapprove
  end

  def inconclusive?
    status == :refer_to_mentor
  end

  private
  # TODO: Memoize
  def data
    HashWithIndifferentAccess.new(super)
  end
end
