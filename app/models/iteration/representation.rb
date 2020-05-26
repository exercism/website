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

  #TOOD: Memoize
  def exercise_representation
    Exercise::Representation.find_by!(
      exercise: iteration.exercise,
      exercise_version: iteration.exercise_version,
      ast_digest: ast_digest
    )
  end

  def self.digest_ast(ast)
    Digest::SHA1.hexdigest(ast)
  end
end
