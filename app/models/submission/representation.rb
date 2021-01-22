class Submission::Representation < ApplicationRecord
  extend Mandate::Memoize

  def self.digest_ast(ast)
    return nil if ast.blank?

    Digest::SHA1.hexdigest(ast)
  end

  belongs_to :submission

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

  memoize
  def exercise_representation
    Exercise::Representation.find_by!(
      exercise: submission.exercise,
      ast_digest: ast_digest
    )
  end
end
