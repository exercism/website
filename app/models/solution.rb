class Solution < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :user
  belongs_to :exercise
  has_one :track, through: :exercise
  has_many :submissions, dependent: :destroy
  has_many :iterations, dependent: :destroy

  has_many :mentor_requests, class_name: "Solution::MentorRequest", dependent: :destroy
  has_many :mentor_discussions, class_name: "Solution::MentorDiscussion", dependent: :destroy

  scope :completed, -> { where.not(completed_at: nil) }
  scope :not_completed, -> { where(completed_at: nil) }

  scope :published, -> { where.not(published_at: nil) }

  before_create do
    # Search engines derive meaning by using hyphens
    # as word-boundaries in URLs. Since we use the
    # solution UUID for URLs, we're removing the hyphen
    # to remove any spurious, accidental, and arbitrary
    # meaning.
    self.uuid = SecureRandom.compact_uuid unless self.uuid

    self.git_slug = exercise.slug unless self.git_slug
    self.git_sha = track.git_head_sha unless self.git_sha
  end

  def self.for(user, exercise)
    Solution.find_by(exercise: exercise, user: user)
  end

  def git_type
    self.class.name.sub("Solution", "").downcase
  end

  def to_param
    raise "We almost never want to auto-generate solution urls. Use the solution_url helper method or use uuid if you're sure you want to do this." # rubocop:disable Layout/LineLength
  end

  def downloaded?
    !!downloaded_at
  end

  def completed?
    !!completed_at
  end

  def published?
    !!published_at
  end

  def has_unlocked_pending_mentoring_request?
    mentor_requests.pending.unlocked.exists?
  end

  def has_locked_pending_mentoring_request?
    mentor_requests.pending.locked.exists?
  end

  def has_in_progress_mentor_discussion?
    mentor_discussions.in_progress.exists?
  end

  memoize
  delegate :instructions, to: :git_exercise

  memoize
  delegate :introduction, to: :git_exercise

  def editor_language
    track.slug
  end

  def editor_solution_files
    files = git_exercise.editor_solution_files

    submission = submissions.last
    if submission # rubocop:disable Style/SafeNavigation
      submission.files.each do |file|
        files[file.filename] = file.content
      end
    end

    files
  end

  # TODO: - Use an actual serializer
  def serialized_submissions
    submissions.map do |i|
      {
        id: i.id,
        testsStatus: i.tests_status
      }
    end
  end

  def anonymised_user_handle
    "anonymous-#{Digest::SHA1.hexdigest("#{id}-#{uuid}")}"
  end

  def update_git_info!
    update!(
      git_slug: exercise.slug,
      git_sha: track.git_head_sha
    )
  end

  memoize
  def git_exercise
    Git::Exercise.for_solution(self)
  end
end
