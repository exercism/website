class Iteration::Analysis < ApplicationRecord
  belongs_to :iteration
  
  scope :ops_successful, -> { where(ops_status: 200) }

  before_create do
    self.status = raw_analysis[:status] unless self.status
    self.comments_data = raw_analysis[:comments] unless self.comments_data
  end
  
  def status
    super.try(&:to_sym)
  end

  def ops_success?
    ops_status == 200
  end

  def ops_errored?
    !ops_success?
  end

  def approved?
    status == :approved
  end

  def disapproved?
    status == :disapproved
  end

  private
  def comments_data
    super
  end

  # TODO Memoize
  def raw_analysis
    HashWithIndifferentAccess.new(super)
  end

end
