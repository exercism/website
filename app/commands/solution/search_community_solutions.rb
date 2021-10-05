class Solution
  class SearchCommunitySolutions
    include Mandate

    DEFAULT_PAGE = 1
    DEFAULT_PER = 25

    def self.default_per
      DEFAULT_PER
    end

    def initialize(exercise, page: nil, per: nil, criteria: nil)
      @exercise = exercise
      @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE # rubocop:disable Style/ConditionalAssignment
      @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per # rubocop:disable Style/ConditionalAssignment
      @criteria = criteria
    end

    def call
      @solutions = exercise.solutions.published

      filter_criteria!
      sort!

      @solutions.page(page).per(per)
    end

    def filter_criteria!
      return if @criteria.blank?

      @solutions = @solutions.joins(:user).where("users.handle LIKE ?", "%#{criteria}%")
    end

    def sort!
      @solutions = @solutions.order(num_stars: :desc, id: :desc)
    end

    private
    attr_reader :exercise, :per, :page, :solutions, :criteria
  end
end
