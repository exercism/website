class Iteration < ApplicationRecord
  belongs_to :solution
  has_many :files, class_name: "IterationFile", dependent: :destroy
  has_many :test_runs, class_name: "Iteration::TestRun"
end
