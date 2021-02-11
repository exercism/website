class Solution < ApplicationRecord
  extend Mandate::Memoize

  enum mentoring_status: { none: 0, requested: 1, in_progress: 2, finished: 3 }, _prefix: true

  belongs_to :user
  belongs_to :exercise
  has_one :track, through: :exercise
  has_many :submissions, dependent: :destroy
  has_many :iterations, dependent: :destroy
  has_many :user_activities, class_name: "User::Activity", dependent: :destroy

  has_many :mentor_requests, class_name: "Solution::MentorRequest", dependent: :destroy
  has_many :mentor_discussions, class_name: "Solution::MentorDiscussion", dependent: :destroy
  has_many :mentors, through: :mentor_discussions

  scope :completed, -> { where.not(completed_at: nil) }
  scope :not_completed, -> { where(completed_at: nil) }

  scope :published, -> { where.not(published_at: nil) }
  scope :not_published, -> { where(published_at: nil) }

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

  delegate :instructions, :introduction, to: :git_exercise
  delegate :solution_files, to: :exercise, prefix: 'exercise'

  def git_type
    self.class.name.sub("Solution", "").downcase
  end

  def to_param
    raise "We almost never want to auto-generate solution urls. Use the solution_url helper method or use uuid if you're sure you want to do this." # rubocop:disable Layout/LineLength
  end

  def status
    return :published if published?
    return :completed if completed?
    return :in_progress if iterated?

    :started
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

  def iterated?
    iterations.exists?
  end

  def has_unlocked_pending_mentoring_request?
    mentor_requests.pending.unlocked.exists?
  end

  def has_locked_pending_mentoring_request?
    mentor_requests.pending.locked.exists?
  end

  def in_progress_mentor_discussion
    mentor_discussions.in_progress.first
  end

  def update_mentoring_status!
    return update_column(:mentoring_status, :in_progress) if mentor_discussions.in_progress.exists?
    return update_column(:mentoring_status, :requested) if mentor_requests.pending.exists?
    return update_column(:mentoring_status, :finished) if mentor_discussions.finished.exists?

    update_column(:mentoring_status, :none)
  end

  # TODO
  def num_loc
    9
  end

  # TODO
  def num_stars
    9
  end

  # TODO
  def num_comments
    9
  end

  # TODO
  def snippet
    '
public class Year
{
  public static bool IsLeap(int year)
  {
      if (year % 4 != 0) return false
      if (year % 100 == 0 && year % 400) return false
      return true;
  }
}
    '.strip
  end

  def editor_language
    track.slug
  end

  def solution_files
    files = exercise_solution_files

    submission = submissions.last
    if submission # rubocop:disable Style/SafeNavigation
      submission.files.each do |file|
        files[file.filename] = file.content
      end
    end

    files
  end

  def broadcast_submissions!
    SubmissionsChannel.broadcast!(self)
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

  def read_file(filepath)
    git_exercise.read_file_blob(filepath)
  end

  memoize
  def git_exercise
    Git::Exercise.for_solution(self)
  end
end
