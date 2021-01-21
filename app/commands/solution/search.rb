class Solution
  class Search
    include Mandate

    def self.per
      25
    end

    def initialize(user, criteria: nil, status: nil, mentoring_status: nil, page: nil, per: nil)
      @user = user
      @criteria = criteria
      @status = status
      @mentoring_status = mentoring_status
      @page = page || 1
      @per = per || self.class.per
    end

    def call
      @solutions = user.solutions
      filter_criteria
      filter_status
      filter_mentoring_status

      @solutions.page(@page).per(@per)
    end

    private
    attr_reader :user, :criteria, :status, :mentoring_status,
      :solutions

    def filter_criteria
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

    def filter_status
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

    def filter_mentoring_status
      return if mentoring_status.blank?

      case mentoring_status.to_sym
      when :none
        @solutions = @solutions.mentoring_status_none
      when :requested
        @solutions = @solutions.mentoring_status_requested
      when :in_progress
        @solutions = @solutions.mentoring_status_in_progress
      when :completed
        @solutions = @solutions.mentoring_status_completed
      end
    end
  end
end
