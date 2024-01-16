class Submission::TestRun < ApplicationRecord
  extend Mandate::Memoize
  include HasToolingJob

  serialize :raw_results, JSON

  belongs_to :track
  belongs_to :submission
  has_one :exercise, through: :submission

  scope :ops_successful, -> { where(ops_status: 200) }

  delegate :solution, to: :submission

  before_create do
    self.version = raw_results[:version].to_i
    self.message = raw_results[:message] unless self.message
    self.output = raw_results[:output] unless self.output
    self.status = raw_results.fetch(:status, :error) unless self.status
    self.uuid = SecureRandom.uuid unless self.uuid

    self.message = self.message.byteslice(0, MESSAGE_MAX_LEN - 1) if self.message.present? && self.message.bytesize > MESSAGE_MAX_LEN

    self.ops_status = 400 if ops_success? && !raw_results[:status]

    self.git_sha = submission.git_sha if self.git_sha.blank?

    # We don't want to just copy this from the submission as we
    # might be creating a HEAD run.
    if self.git_important_files_hash.blank?
      self.git_important_files_hash = Git::GenerateHashForImportantExerciseFiles.(
        exercise, git_sha: self.git_sha
      )
    end
  end

  before_validation on: :create do
    self.track = submission.track unless track
  end

  def self.for!(submission)
    where(submission:).last
  end

  def status = super.try(&:to_sym)
  def ops_success? = ops_status == 200
  def timed_out? = ops_status == 408
  def ops_errored? = !ops_success?
  def passed? = status == :pass
  def errored? = status == :error
  def failed? = status == :fail

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
    include Mandate

    initialize_with :test

    def to_h
      {
        name: test[:name].to_s,
        status: test[:status].try(&:to_sym),
        test_code: test[:test_code],
        message: test[:message],
        message_html: Ansi::RenderHTML.(test[:message]),
        expected: test[:expected],
        output: test[:output],
        output_html: Ansi::RenderHTML.(test[:output]),
        task_id: test[:task_id]&.to_i
      }
    end

    def to_json(*_args) = to_h.to_json

    def as_json(*_args) = to_h
  end

  MESSAGE_MAX_LEN = 65_536
  private_constant :TestResult, :MESSAGE_MAX_LEN
end
