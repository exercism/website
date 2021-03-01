class Submission::TestRun < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :submission

  scope :ops_successful, -> { where(ops_status: 200) }

  before_create do
    self.status = raw_results.fetch(:status, :error) unless self.status
    self.message = raw_results[:message] unless self.message
    self.tests = raw_results[:tests] unless self.tests
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

  def passed?
    status == :pass
  end

  def errored?
    status == :error
  end

  def failed?
    status == :fail
  end

  memoize
  def test_results
    tests.to_a.map do |test|
      TestResult.new(HashWithIndifferentAccess.new(test))
    end
  end

  def broadcast!
    Submission::TestRunsChannel.broadcast!(self)
  end

  private
  def raw_results
    HashWithIndifferentAccess.new(super)
  end

  class TestResult
    def initialize(test)
      @test = test
    end

    def to_h
      {
        name: test[:name],
        status: test[:status].try(&:to_sym),
        test_code: test[:test_code],
        message: test[:message],
        expected: test[:expected],
        output: test[:output],
        output_html: test[:output].present? ? Ansi::To::Html.new(test[:output]).to_html : nil
      }
    end

    def to_json(*_args)
      to_h.to_json
    end

    def as_json(*_args)
      to_h
    end

    private
    attr_reader :test
  end
  private_constant :TestResult
end
