class Iteration::Representation < ApplicationRecord
  belongs_to :iteration

  before_create do
    self.ast_digest = Digest::SHA1.hexdigest(ast)
  end
end
