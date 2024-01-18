class GenericExercise < ApplicationRecord
  enum status: { active: 0, deprecated: 1 }

  def status = super.to_sym
end
