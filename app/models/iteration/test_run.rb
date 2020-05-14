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

  def ops_success?
    ops_status == 200
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

  # TODO Memoize
  def test_results
    tests.map do |test|
      TestResult.new(HashWithIndifferentAccess.new(test))
    end
  end

  private
  # TODO Memoize
  def raw_results
    HashWithIndifferentAccess.new(super)
  end

  class TestResult 
    attr_reader :name, :status, :cmd, :message, :expected

    def initialize(test)
      @name = test[:name]
      @status = test[:status].to_sym
      @cmd = test[:cmd]
      @message = test[:message]
      @expected = test[:expected]
      @output = test[:output]
    end

    def output_html
      output ? Ansi::To::Html.new(output).to_html : nil
    end

    private
    attr_reader :output
  end
  private_constant :TestResult
end
