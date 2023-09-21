class Submission::Representation < ApplicationRecord
  extend Mandate::Memoize
  include HasToolingJob

  def self.digest_ast(ast)
    return nil if ast.blank?

    Digest::SHA1.hexdigest(ast)
  end

  belongs_to :submission
  belongs_to :mentored_by, optional: true, class_name: "User"
  belongs_to :track

  has_one :solution, through: :submission
  has_one :iteration, through: :submission
  has_one :exercise, through: :solution

  has_one :exercise_representation,
    -> { order('exercise_representations.id desc') },
    foreign_key: :exercise_id_and_ast_digest_idx_cache,
    primary_key: :exercise_id_and_ast_digest_idx_cache,
    class_name: "Exercise::Representation",
    inverse_of: :submission_representations

  before_create do
    self.ast_digest = self.class.digest_ast(ast) unless self.ast_digest
    self.exercise_id_and_ast_digest_idx_cache = "#{submission.exercise_id}|#{ast_digest}"

    self.ops_status = OPS_STATUS_ERRORED if self.ast_digest.blank?
  end

  before_validation on: :create do
    self.track = submission.track unless track
  end

  delegate :has_feedback?, to: :exercise_representation

  def self.for!(submission)
    where(submission:).last
  end

  def ops_success? = ops_status == OPS_STATUS_SUCCESS
  def ops_errored? = !ops_success?

  OPS_STATUS_SUCCESS = 200
  OPS_STATUS_ERRORED = 500
  private_constant :OPS_STATUS_SUCCESS, :OPS_STATUS_ERRORED
end
