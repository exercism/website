class Submission < ApplicationRecord
  belongs_to :solution
  has_one :exercise, through: :solution
  has_one :track, through: :exercise

  has_many :files, class_name: "Submission::File", dependent: :destroy
  has_many :test_runs, class_name: "Submission::TestRun", dependent: :destroy
  has_many :analyses, class_name: "Submission::Analysis", dependent: :destroy
  has_many :representations, class_name: "Submission::Representation", dependent: :destroy
  has_many :discussion_posts, class_name: "Submission::DiscussionPost", dependent: :destroy

  enum tests_status: { not_queued: 0, queued: 1, passed: 2, failed: 3, errored: 4, exceptioned: 5, cancelled: 6 }, # rubocop:disable Layout/LineLength
       _prefix: "tests"

  # TODO: Find a better name for the 0 state here to represent something where no action has been taken.
  enum representation_status: { not_queued: 0, queued: 1, approved: 2, disapproved: 3, inconclusive: 4, exceptioned: 5, cancelled: 6 }, # rubocop:disable Layout/LineLength
       _prefix: "representation"

  # TODO: Find a better name for the 0 state here to represent something where no action has been taken.
  enum analysis_status: { not_queued: 0, queued: 1, approved: 2, disapproved: 3, inconclusive: 4, exceptioned: 5, cancelled: 6 }, # rubocop:disable Layout/LineLength
       _prefix: "analysis"

  before_create do
    self.git_slug = solution.git_slug
    self.git_sha = solution.git_sha
  end

  def broadcast!
    SubmissionsChannel.broadcast!(solution)
    SubmissionChannel.broadcast!(self)
  end

  def exercise_version
    # TODO: Read this back from git
    '15.8.12'
    # track.repo.exercise(git_slug, git_sha).version
  end

  def serialized
    {
      id: id,
      track: track.title,
      exercise: exercise.title,
      testsStatus: tests_status,
      representationStatus: representation_status,
      analysisStatus: analysis_status
    }
  end
end
