class Submission < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :solution
  has_one :exercise, through: :solution
  has_one :track, through: :exercise
  has_one :iteration, dependent: :destroy

  has_many :files, class_name: "Submission::File", dependent: :destroy
  has_one :test_run, class_name: "Submission::TestRun", dependent: :destroy
  has_one :analysis, class_name: "Submission::Analysis", dependent: :destroy
  has_one :submission_representation, class_name: "Submission::Representation", dependent: :destroy
  has_one :exercise_representation, through: :submission_representation

  # TODO: It's important that we enforce rules on these to stop things from
  # going from the success states (passed/failed/errored/generated/completed)
  # backwards to the pending states.

  # TODO: Find a better name for the 0 state for these to represent something where no action has been taken.
  enum tests_status: { not_queued: 0, queued: 1, passed: 2, failed: 3, errored: 4, exceptioned: 5, cancelled: 6 }, _prefix: "tests" # rubocop:disable Layout/LineLength
  enum representation_status: { not_queued: 0, queued: 1, generated: 2, exceptioned: 3, cancelled: 5 }, _prefix: "representation" # rubocop:disable Layout/LineLength
  enum analysis_status: { not_queued: 0, queued: 1, completed: 3, exceptioned: 4, cancelled: 5 }, _prefix: "analysis"

  before_create do
    self.git_slug = solution.git_slug
    self.git_sha = solution.git_sha
  end

  def to_param
    uuid
  end

  def broadcast!
    SubmissionChannel.broadcast!(self)
  end

  def tests_pending?
    %w[not_queued queued].include?(tests_status)
  end

  def tests_passed?
    tests_status == "passed"
  end

  def automated_feedback_pending?
    return true if !representation_generated? && !analysis_completed?
    return false if has_automated_feedback?
    return true if representation_queued? || representation_not_queued?
    return true if analysis_queued? || analysis_not_queued?

    false
  end

  def has_automated_feedback?
    num_automated_comments_by_type.values.sum.positive?
  end

  %i[essential actionable non_actionable].each do |type|
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

    # Other users can only see if it's an iteration
    return false unless iteration

    # Current mentors can see submissions
    return true if solution.mentors.include?(user)

    # All mentors can see files on pending requests
    return true if solution.mentor_requests.pending.any? && user.mentor?

    # Everyone can see published iterations
    return true if solution.published? # TODO: Change this to iteration.published

    false
  end

  memoize
  def representer_feedback
    return nil unless exercise_representation&.has_feedback?

    author = exercise_representation.feedback_author

    {
      html: exercise_representation.feedback_html,
      author: {
        name: author.name,
        reputation: author.reputation,
        avatar_url: author.avatar_url,
        profile_url: "#" # TODO
      }
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
      non_actionable: analysis&.num_informative_comments.to_i +
        analysis&.num_celebratory_comments.to_i
    }.tap do |values|
      if exercise_representation&.has_essential_feedback?
        values[:essential] += 1
      elsif exercise_representation&.has_actionable_feedback?
        values[:actionable] += 1
      elsif exercise_representation&.has_feedback?
        values[:non_actionable] += 1
      end
    end
  end
end
