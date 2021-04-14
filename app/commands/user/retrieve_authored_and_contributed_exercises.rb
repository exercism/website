class User
  class RetrieveAuthoredAndContributedExercises
    include Mandate

    DEFAULT_PAGE = 1
    DEFAULT_PER = 25

    def self.default_per
      DEFAULT_PER
    end

    def initialize(user, page: nil)
      @user = user
      @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE # rubocop:disable Style/ConditionalAssignment
    end

    def call
      # TODO: Make this work as an inner query, not an array
      ids = @user.authored_exercises.select(:id) +
            @user.contributed_exercises.select(:id)

      Exercise.
        where(id: ids).
        order(id: :desc).
        page(page).
        per(20)
    end

    private
    attr_reader :page
  end
end
