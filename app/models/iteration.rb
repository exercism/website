class Iteration < ApplicationRecord
  belongs_to :solution, counter_cache: :num_iterations
  belongs_to :submission

  has_many :mentor_discussion_posts, class_name: "Mentor::DiscussionPost", dependent: :destroy

  has_one :exercise, through: :solution
  has_one :track, through: :exercise
  has_one :test_run, through: :iteration

  delegate :tests_status,
    :files,
    :automated_feedback_pending,
    :representer_feedback,
    :analyzer_feedback, to: :submission

  %i[essential actionable non_actionable].each do |type|
    delegate :"num_#{type}_automated_comments", to: :submission
    delegate :"has_#{type}_automated_feedback?", to: :submission
  end

  after_save_commit do
    solution.update_status!
    solution.update_iteration_status!
  end

  def status
    Status.new(lambda {
      return :testing                           if submission.tests_pending?
      return :tests_failed                      unless submission.tests_passed?
      return :analyzing                         if submission.automated_feedback_pending?
      return :essential_automated_feedback      if submission.has_essential_automated_feedback?
      return :actionable_automated_feedback     if submission.has_actionable_automated_feedback?
      return :non_actionable_automated_feedback if submission.has_non_actionable_automated_feedback?

      :no_automated_feedback
    }.())
  end

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

  class Status
    attr_reader :status

    def initialize(status)
      @status = status.to_sym
    end

    delegate :to_s, to: :status

    def to_sym
      status
    end

    def inspect
      "Iteration::Status (#{status})"
    end

    %i[
      testing tests_failed analyzing
      essential_automated_feedback actionable_automated_feedback
      non_actionable_automated_feedback no_automated_feedback
    ].each do |s|
      define_method "#{s}?" do
        status == s
      end
    end
  end
  private_constant :Status
end
