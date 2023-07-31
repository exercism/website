class User::RetrieveAuthoredAndContributedExercises
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 25

  def self.default_per
    DEFAULT_PER
  end

  def initialize(user, page: nil,
                 sorted: true, paginated: true)
    @user = user
    @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
    @sorted = sorted
    @paginated = paginated
  end

  def call
    setup!
    sort! if sorted?
    paginate! if paginated?
    @exercises
  end

  def setup!
    # TODO: (Optional) Make this work as an inner query, not an array
    ids = @user.authored_exercises.select(:id) +
          @user.contributed_exercises.select(:id)

    @exercises = Exercise.where(id: ids)
  end

  def sort!
    @exercises = @exercises.order(id: :desc)
  end

  def paginate!
    @exercises = @exercises.page(page).per(self.class.default_per)
  end

  private
  attr_reader :page

  %i[sorted paginated].each do |attr|
    define_method("#{attr}?") { instance_variable_get("@#{attr}") }
  end
end
