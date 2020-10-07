class Submission < ApplicationRecord
  belongs_to :solution
  has_one :exercise, through: :solution
  has_one :track, through: :exercise

  has_many :files, class_name: "Submission::File", dependent: :destroy
  has_many :test_runs, class_name: "Submission::TestRun", dependent: :destroy
  has_many :analyses, class_name: "Submission::Analysis", dependent: :destroy
  has_many :representations, class_name: "Submission::Representation", dependent: :destroy
  has_many :discussion_posts, class_name: "Submission::DiscussionPost", dependent: :destroy

  enum tests_status: { pending: 0, passed: 1, failed: 2, errored: 3, exceptioned: 4, cancelled: 5 }, # rubocop:disable Layout/LineLength
       _prefix: "tests"

  enum representation_status: { pending: 0, approved: 1, disapproved: 2, inconclusive: 3, exceptioned: 4, cancelled: 5 }, # rubocop:disable Layout/LineLength
       _prefix: "representation"

  enum analysis_status: { pending: 0, approved: 1, disapproved: 2, inconclusive: 3, exceptioned: 4, cancelled: 5 }, # rubocop:disable Layout/LineLength
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
    track.repo.exercise(git_slug, git_sha).version
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
