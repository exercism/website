class Submission::Representation < ApplicationRecord
  belongs_to :submission
  has_many :exercise_representations, class_name: "Submission::Representation",
                                      foreign_key: :ast_digest,
                                      primary_key: :ast_digest,
                                      inverse_of: :submission_representations

  before_create do
    self.ast_digest = self.class.digest_ast(ast)
  end

  def ops_success?
    ops_status == 200
  end

  def ops_errored?
    !ops_success?
  end

  # TOOD: Memoize
  def exercise_representation
    Exercise::Representation.find_by!(
      exercise: submission.exercise,
      exercise_version: submission.exercise_version,
      ast_digest: ast_digest
    )
  end

  def self.digest_ast(ast)
    Digest::SHA1.hexdigest(ast)
  end
end
