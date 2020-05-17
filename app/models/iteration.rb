class Iteration < ApplicationRecord
  belongs_to :solution
  has_many :files, class_name: "Iteration::File", dependent: :destroy
  has_many :test_runs, class_name: "Iteration::TestRun"
  has_many :analyses, class_name: "Iteration::Analysis"

  enum tests_status: [:pending, :passed, :failed, :errored, :exceptioned], _prefix: "tests"
  enum representation_status: [:pending, :approved, :disapproved, :inclusive, :exceptioned], _prefix: "representation"
  enum analysis_status: [:pending, :approved, :disapproved, :exceptioned], _prefix: "analysis"

  before_create do
    self.git_slug = solution.git_slug
    self.git_sha = solution.git_sha
  end
end

=begin
- Tests Passwed
- Tests Fail
- Tests Error
- Representation Approved
- Representation Disapproved
- Representation Inconclusive
- Representation Errored
- Analysis Approved
- Analysis Disapproved
- Analysis Errored
=end
