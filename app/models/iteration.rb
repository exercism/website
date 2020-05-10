class Iteration < ApplicationRecord
  belongs_to :solution
  has_many :files, class_name: "IterationFile", dependent: :destroy
end
