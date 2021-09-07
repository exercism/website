class Submission::TestRun < ApplicationRecord
  extend Mandate::Memoize

  serialize :raw_results, JSON

  belongs_to :submission

  scope :ops_successful, -> { where(ops_status: 200) }

  delegate :solution, to: :submission

  before_create do
    self.version = raw_results[:version].to_i
    self.message = raw_results[:message] unless self.message
    self.output = raw_results[:output] unless self.output
    self.status = raw_results.fetch(:status, :error) unless self.status
    self.uuid = SecureRandom.uuid unless self.uuid

    self.ops_status = 400 if ops_success? && !raw_results[:status]
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
    raw_results[:tests].to_a.map do |test|
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
        message_html: Ansi::RenderHTML.(test[:message]),
        expected: test[:expected],
        output: test[:output],
        output_html: Ansi::RenderHTML.(test[:output])
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
