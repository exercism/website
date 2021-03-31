class Solution
  class SearchUserSolutions
    include Mandate

    DEFAULT_PAGE = 1
    DEFAULT_PER = 25

    def self.default_per
      DEFAULT_PER
    end

    def initialize(user, criteria: nil, status: nil, mentoring_status: nil, page: nil, per: nil, order: nil)
      @user = user
      @criteria = criteria
      @status = status
      @mentoring_status = mentoring_status
      @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE # rubocop:disable Style/ConditionalAssignment
      @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per # rubocop:disable Style/ConditionalAssignment
      @order = order
    end

    def call
      @solutions = user.solutions
      filter_criteria!
      filter_status!
      filter_mentoring_status!
      sort!

      @solutions.page(page).per(per)
    end

    private
    attr_reader :user, :criteria, :status, :mentoring_status,
      :per, :page, :order,
      :solutions

    def filter_criteria!
      return if criteria.blank?

      @solutions = @solutions.joins(exercise: :track)
      criteria.strip.split(" ").each do |crit|
        @solutions = @solutions.where(
          "exercises.title LIKE ? OR tracks.title LIKE ?",
          "#{crit}%",
          "#{crit}%"
        )
      end
    end

    def filter_status!
      return if status.blank?

      case status.to_sym
      when :in_progress
        @solutions = @solutions.not_completed
      when :all_completed
        @solutions = @solutions.completed
      when :published
        @solutions = @solutions.published
      when :not_published
        @solutions = @solutions.completed.not_published
      end
    end

    def filter_mentoring_status!
      return if mentoring_status.blank?

      case mentoring_status.to_sym
      when :none
        @solutions = @solutions.mentoring_status_none
      when :requested
        @solutions = @solutions.mentoring_status_requested
      when :in_progress
        @solutions = @solutions.mentoring_status_in_progress
      when :finished
        @solutions = @solutions.mentoring_status_finished
      end
    end

    def sort!
      case order&.to_sym
      when :oldest_first
        @solutions = @solutions.order(id: :asc)
      else # :newest_first
        @solutions = @solutions.order(id: :desc)
      end
    end
  end
end
