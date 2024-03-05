class Submission < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :track
  belongs_to :exercise
  belongs_to :solution
  belongs_to :approach, class_name: "Exercise::Approach", optional: true
  has_one :user, through: :solution
  has_one :iteration, dependent: :destroy

  has_many :files, class_name: "Submission::File", dependent: :destroy

  # A submission can have many different test_runs for different git_shas
  has_many :test_runs, class_name: "Submission::TestRun", dependent: :destroy

  # A head test run is one that's up to date with the head exercise's important files hash
  # We use order id desc to get the latest
  has_one :head_test_run, # rubocop:disable Rails/InverseOf
    lambda {
      order(id: :desc).
        joins(submission: :exercise).
        where('submission_test_runs.git_important_files_hash = exercises.git_important_files_hash')
    },
    class_name: "Submission::TestRun", dependent: :destroy

  # The "normal" one is the one run against the same git_important_files_hash as the submission
  # We again use order id desc to get the latest
  has_one :test_run, # rubocop:disable Rails/InverseOf
    lambda {
      order(id: :desc).
        joins(:submission).
        where('submission_test_runs.git_important_files_hash = submissions.git_important_files_hash')
    },
    class_name: "Submission::TestRun", dependent: :destroy
  has_one :analysis, class_name: "Submission::Analysis", dependent: :destroy
  has_one :submission_representation, # rubocop:disable Rails/InverseOf
    ->(s) { where(exercise_representer_version: s.exercise_representer_version).order(id: :desc) },
    class_name: "Submission::Representation", dependent: :destroy
  has_one :exercise_representation, through: :submission_representation
  has_many :ai_help_records, class_name: "Submission::AIHelpRecord", dependent: :destroy

  # TODO: It's important that we enforce rules on these to stop things from
  # going from the success states (passed/failed/errored/generated/completed)
  # backwards to the pending states.
  enum tests_status: { not_queued: 0, queued: 1, passed: 2, failed: 3, errored: 4, exceptioned: 5, cancelled: 6 }, _prefix: "tests"
  enum representation_status: { not_queued: 0, queued: 1, generated: 2, exceptioned: 3, cancelled: 5 }, _prefix: "representation"
  enum analysis_status: { not_queued: 0, queued: 1, completed: 3, exceptioned: 4, cancelled: 5 }, _prefix: "analysis"

  scope :tagged, -> { where.not(tags: nil) }
  scope :untagged, -> { where(tags: nil) }
  scope :has_iteration, -> { joins(:iteration) }

  before_validation on: :create do
    self.track = solution.track unless track
    self.exercise = solution.exercise unless exercise
  end

  before_create do
    self.git_slug = solution.git_slug
    self.git_sha = solution.git_sha if git_sha.blank?
    self.git_important_files_hash = solution.git_important_files_hash if self.git_important_files_hash.blank?
  end

  after_save_commit do
    solution.update_iteration_status! if iteration
  end

  def to_param = uuid

  def broadcast!
    SubmissionChannel.broadcast!(self)
  end

  def write_to_efs!
    dir = [Exercism.config.efs_submissions_mount_point, uuid].join('/')
    return if Dir.exist?(dir)

    files.each(&:write_to_efs!)
  end

  def tests_passed?
    tests_status == "passed"
  end

  def automated_feedback_pending?
    return false if (representation_exceptioned? || representation_cancelled?) &&
                    (analysis_exceptioned? || analysis_cancelled?)
    return false if representation_not_queued? && analysis_not_queued?

    # TODO: materialize the track's has_representer and has_analyzer status to the
    # submission when it is created, and then use those here instead of the track's
    # status fields
    return true if !representation_generated? && !analysis_completed? && track.has_analyzer?
    return true if representation_queued? || representation_not_queued?
    return true if (analysis_queued? || analysis_not_queued?) && track.has_analyzer?

    false
  end

  def has_automated_feedback? = num_automated_comments_by_type.values.sum.positive?

  %i[essential actionable non_actionable celebratory].each do |type|
    define_method "num_#{type}_automated_comments" do
      num_automated_comments_by_type[type]
    end
    define_method "has_#{type}_automated_feedback?" do
      send("num_#{type}_automated_comments").positive?
    end
  end

  def viewable_by?(user)
    # A user can always see their own stuff
    return true if solution.user == user

    # Admins can always see submissions
    return true if user&.admin?

    # Other users can only see if it's an iteration
    return false unless iteration

    # Current mentors can see submissions
    return true if user && solution.mentors.include?(user)

    # All mentors can see files on pending requests
    return true if user && solution.mentor_requests.pending.any? && user.mentor?

    # Non-iteration submissions can never be seen
    # Everyone can see published iterations
    iteration&.published?
  end

  def files_for_editor
    # Merge the submission files into the exercise files. If we find a
    # file we don't expect, that it as type: :legacy
    files.each_with_object(solution.exercise_files_for_editor) do |file, merged_files|
      type = merged_files.key?(file.filename) ? :solution : :legacy

      merged_files[file.filename] = {
        type:,
        content: file.content,
        digest: file.digest
      }
    end
  end

  # We allow repo overriding for when we want to run
  # a submission against newer tests
  def valid_filepaths(repo = exercise_repo)
    repo ||= exercise_repo
    files.map(&:filename).select do |filepath|
      repo.valid_submission_filepath?(filepath)
    end
  end

  # We allow repo overriding for when we want to run
  # a submission against newer tests
  def exercise_files(repo = exercise_repo)
    repo.tooling_files.reject do |filepath, _|
      valid_filepaths(repo).include?(filepath)
    end
  end

  memoize
  def exercise_repo = Git::Exercise.for_solution(solution)

  memoize
  def representer_feedback
    return nil unless exercise_representation&.has_feedback?

    author = exercise_representation.feedback_author
    editor = exercise_representation.feedback_editor

    {
      html: exercise_representation.feedback_html,
      author: {
        name: author.name,
        reputation: author.reputation,
        flair: author.flair,
        avatar_url: author.avatar_url,
        profile_url: author.profile ? Exercism::Routes.profile_url(author) : nil
      },
      editor: if editor.present?
                {
                  name: editor.name,
                  flair: author.flair,
                  reputation: editor.reputation,
                  avatar_url: editor.avatar_url,
                  profile_url: editor.profile ? Exercism::Routes.profile_url(editor) : nil
                }
              end
    }
  end

  memoize
  def analyzer_feedback
    return nil unless analysis&.has_comments?

    {
      summary: analysis.summary,
      comments: analysis.comments
    }
  end

  private
  memoize
  def num_automated_comments_by_type
    {
      essential: analysis&.num_essential_comments.to_i,
      actionable: analysis&.num_actionable_comments.to_i,
      non_actionable: analysis&.num_informative_comments.to_i,
      celebratory: analysis&.num_celebratory_comments.to_i
    }.tap do |values|
      if exercise_representation&.has_essential_feedback?
        values[:essential] += 1
      elsif exercise_representation&.has_actionable_feedback?
        values[:actionable] += 1
      elsif exercise_representation&.has_celebratory_feedback?
        values[:celebratory] += 1
      elsif exercise_representation&.has_feedback?
        values[:non_actionable] += 1
      end
    end
  end
end
