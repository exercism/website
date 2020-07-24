class Iteration < ApplicationRecord
  belongs_to :solution
  has_one :exercise, through: :solution
  has_one :track, through: :exercise

  has_many :files, class_name: "Iteration::File", dependent: :destroy
  has_many :test_runs, class_name: "Iteration::TestRun", dependent: :destroy
  has_many :analyses, class_name: "Iteration::Analysis", dependent: :destroy
  has_many :representations, class_name: "Iteration::Representation", dependent: :destroy
  has_many :discussion_posts, class_name: "Iteration::DiscussionPost", dependent: :destroy

  enum tests_status: { pending: 0, passed: 1, failed: 2, errored: 3, exceptioned: 4 },
       _prefix: "tests"

  enum representation_status: { pending: 0, approved: 1, disapproved: 2, inconclusive: 3, exceptioned: 4 },
       _prefix: "representation"

  enum analysis_status: { pending: 0, approved: 1, disapproved: 2, inconclusive: 3, exceptioned: 4 },
       _prefix: "analysis"

  before_create do
    self.git_slug = solution.git_slug
    self.git_sha = solution.git_sha
  end

  def broadcast!
    IterationsChannel.broadcast!(solution)
    IterationChannel.broadcast!(self)
  end

  def exercise_version
    track.repo.exercise(git_slug, git_sha).version
  end

  def serialized
    {
      id: id,
      testsStatus: tests_status,
      representationStatus: representation_status,
      analysisStatus: analysis_status
    }
  end
end
