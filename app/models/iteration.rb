class Iteration < ApplicationRecord
  belongs_to :solution, counter_cache: :num_iterations
  belongs_to :submission
  has_many :files, through: :submission

  has_many :mentor_discussion_posts, class_name: "Mentor::DiscussionPost", dependent: :destroy

  has_one :exercise, through: :solution
  has_one :track, through: :exercise
  has_one :user, through: :solution
  has_one :test_run, through: :iteration

  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :latest, lambda {
    not_deleted.
      joins("LEFT JOIN `iterations` AS `i` ON `i`.`solution_id` = `iterations`.`solution_id` AND `i`.`deleted_at` IS NULL AND `i`.`idx` > `iterations`.`idx`"). # rubocop:disable Layout/LineLength
      where('`i`.`id` IS NULL')
  }

  delegate :tests_status,
    :files_for_editor,
    :automated_feedback_pending,
    :representer_feedback,
    :analyzer_feedback, to: :submission

  %i[essential actionable non_actionable celebratory].each do |type|
    delegate :"num_#{type}_automated_comments", to: :submission
    delegate :"has_#{type}_automated_feedback?", to: :submission
  end

  # This is like this because we also call it externally
  # as we don't use ActiveRecord to create the iteration record
  after_save_commit :handle_after_save!

  def status
    Status.new(lambda {
      return :deleted if deleted?
      return :untested                          if submission.tests_not_queued?
      return :testing                           if submission.tests_queued?
      return :tests_failed                      unless submission.tests_passed?
      return :analyzing                         if submission.automated_feedback_pending?
      return :essential_automated_feedback      if has_essential_automated_feedback?
      return :actionable_automated_feedback     if has_actionable_automated_feedback?
      return :celebratory_automated_feedback    if has_celebratory_automated_feedback?
      return :non_actionable_automated_feedback if has_non_actionable_automated_feedback?

      :no_automated_feedback
    }.())
  end

  def latest?
    solution.latest_iteration == self
  end

  def deleted? = !!deleted_at

  def published?
    solution.published? && (
      !solution.published_iteration_id ||
      solution.published_iteration_id == id
    )
  end

  def viewable_by?(user)
    solution.mentors.include?(user) || solution.user == user
  end

  def broadcast!
    IterationChannel.broadcast!(self)
    solution.broadcast!
  end

  def handle_after_save!
    solution.update_status!
    solution.update_iteration_status!
    solution.update!(last_iterated_at: Time.current)
  end

  class Status
    attr_reader :status

    def initialize(status)
      @status = status.to_sym
    end

    delegate :to_s, to: :status

    def to_sym = status
    def inspect = "Iteration::Status (#{status})"

    %i[
      untested testing tests_failed analyzing
      essential_automated_feedback actionable_automated_feedback
      non_actionable_automated_feedback celebratory_automated_feedback
      no_automated_feedback
    ].each do |s|
      define_method "#{s}?" do
        status == s
      end
    end
  end
  private_constant :Status
end
