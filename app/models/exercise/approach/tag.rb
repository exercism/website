class Exercise::Approach::Tag < ApplicationRecord
  belongs_to :approach,
    class_name: "Exercise::Approach",
    foreign_key: :exercise_approach_id,
    inverse_of: :tags

  enum condition_type: { all: 0, any: 1, not: 2 }, _prefix: true

  def condition_type = super.to_sym
end
