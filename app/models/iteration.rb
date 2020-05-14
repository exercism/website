class Iteration < ApplicationRecord
  belongs_to :solution
  has_many :files, class_name: "Iteration::File", dependent: :destroy
  has_many :test_runs, class_name: "Iteration::TestRun"
  has_many :analyses, class_name: "Iteration::Analysis"
end
