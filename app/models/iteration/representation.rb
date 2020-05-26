class Iteration::Representation < ApplicationRecord
  belongs_to :iteration

  before_create do
    self.ast_digest = self.class.digest_ast(ast)
  end

  def ops_success?
    ops_status == 200
  end

  def ops_errored?
    !ops_success?
  end

  def exercise_representation
    Exercise::Representation.find_by!(
      exercise: exercise,
      exercise_version: exercise_version,
      ast_digest: iteration_representation.ast_digest
    )
  end

  def self.digest_ast(ast)
    Digest::SHA1.hexdigest(ast)
  end
end
