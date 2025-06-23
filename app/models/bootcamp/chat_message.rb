class Bootcamp::ChatMessage < ApplicationRecord
  belongs_to :solution, class_name: "Bootcamp::Solution"
  has_one :user, through: :solution

  enum author: { user: 0, llm: 1 }
end
