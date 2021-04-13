class Solution < ApplicationRecord
  extend Mandate::Memoize

  enum mentoring_status: { none: 0, requested: 1, in_progress: 2, finished: 3 }, _prefix: true
  enum status: { started: 0, iterated: 1, completed: 2, published: 3 }, _prefix: true

  belongs_to :user
  belongs_to :exercise
  has_one :track, through: :exercise

  # TODO: This might be horrific for performance
  has_one :user_track,
    lambda { |s|
      joins(track: :exercises).
        where('exercises.id': s.exercise_id)
    },
    foreign_key: :user_id,
    primary_key: :user_id,
    touch: true,
    inverse_of: :solutions

  has_many :submissions, dependent: :destroy
  has_many :iterations, dependent: :destroy
  has_many :user_activities, class_name: "User::Activity", dependent: :destroy

  has_many :mentor_requests, class_name: "Mentor::Request", dependent: :destroy
  has_many :mentor_discussions, class_name: "Mentor::Discussion", dependent: :destroy
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

  before_update do
    self.status = determine_status
  end

  def self.for(user, exercise)
    Solution.find_by(exercise: exercise, user: user)
  end

  delegate :instructions, :introduction, :source, :source_url, to: :git_exercise
  delegate :solution_files, to: :exercise, prefix: 'exercise'

  memoize
  def latest_iteration
    iterations.last
  end

  def status
    super.to_sym
  end

  def mentoring_status
    super.to_sym
  end

  def iteration_status
    super&.to_sym
  end

  # TODO: Karlo
  def has_unsubmitted_code?
    false
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

  def update_status!
    new_status = determine_status
    update(status: new_status) if status != new_status
  end

  def update_iteration_status!
    new_status = iterations.last&.status.to_s
    update_column(:iteration_status, new_status) if iteration_status != new_status
  end

  def update_mentoring_status!
    new_status = determine_mentoring_status
    update(mentoring_status: new_status) if mentoring_status != new_status
  end

  # TODO
  def num_views
    1270
  end

  # TODO
  def num_loc
    18
  end

  # TODO
  def num_stars
    10
  end

  # TODO
  def num_comments
    3
  end

  # TODO
  def out_of_date?
    true
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

  def broadcast!
    SolutionChannel.broadcast!(self)
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
    return Solution::GenerateReadmeFile.(self) if filepath == 'README.md'
    return Solution::GenerateHelpFile.(self) if filepath == 'HELP.md'
    return Solution::GenerateHintsFile.(self) if filepath == 'HINTS.md'

    git_exercise.read_file_blob(filepath)
  end

  memoize
  def git_exercise
    Git::Exercise.for_solution(self)
  end

  private
  def determine_status
    return :published if published?
    return :completed if completed?
    return :iterated if iterated?

    :started
  end

  def determine_mentoring_status
    return :in_progress if mentor_discussions.in_progress.exists?
    return :requested if mentor_requests.pending.exists?
    return :finished if mentor_discussions.finished.exists?

    :none
  end
end
