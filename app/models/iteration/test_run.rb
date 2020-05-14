class Iteration::TestRun < ApplicationRecord
  belongs_to :iteration
  
  scope :ops_successful, -> { where(ops_status: 200) }

  before_create do
    self.status = raw_results[:status] unless self.status
    self.message = raw_results[:message] unless self.message
    self.tests = raw_results[:tests] unless self.tests
  end
  
  def status
    super.try(&:to_sym)
  end

  def raw_results
    HashWithIndifferentAccess.new(super)
  end

  def passed?
    status == :pass
  end

  def errored?
    status == :error
  end

  def failed?
    status == :fail
  end
end
