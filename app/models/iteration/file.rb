class Iteration::File < ApplicationRecord
  belongs_to :iteration

  def content
    Iteration::File::Download.(uuid, filename)
  end
end
