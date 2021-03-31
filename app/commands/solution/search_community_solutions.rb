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

      # TODO: Implement this properly.
      @solutions = solutions.joins(:user).where("users.handle LIKE ?", "%#{criteria}%") if @criteria.present?

      @solutions.page(page).per(per)
    end

    private
    attr_reader :exercise, :per, :page, :solutions, :criteria
  end
end
