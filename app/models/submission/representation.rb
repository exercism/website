class Submission::Representation < ApplicationRecord
  extend Mandate::Memoize

  def self.digest_ast(ast)
    return nil if ast.blank?

    Digest::SHA1.hexdigest(ast)
  end

  belongs_to :submission
  has_one :solution, through: :submission
  has_one :exercise, through: :solution

  # TOOD: We're going to need some indexes here!
  has_one :exercise_representation,
    ->(sr) { where("exercise_representations.exercise_id": sr.solution.exercise_id) },
    foreign_key: :ast_digest,
    primary_key: :ast_digest,
    class_name: "Exercise::Representation",
    inverse_of: :submission_representations

  before_create do
    # TODO: if there is no AST digest, this this
    # *MUST* set the status to an ops_error.
    self.ast_digest = self.class.digest_ast(ast) unless self.ast_digest
  end

  delegate :has_feedback?, to: :exercise_representation

  def ops_success?
    ops_status == 200
  end

  def ops_errored?
    !ops_success?
  end
end
