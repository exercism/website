class Exercise::Representation::Search
  include Mandate

  # Use class method rather than constant for easier stubbing during testing
  def self.requests_per_page = 20

  def initialize(criteria: nil, status: nil, user: nil, track: nil, order: :num_occurances, page: 1)
    @criteria = criteria
    @status = status.try(&:to_sym)
    @user = user
    @track = track
    @order = order.try(&:to_sym)
    @page = page
  end

  def call
    @representations = Exercise::Representation.joins(exercise: :track)
    filter_status!
    filter_user!
    filter_track!
    filter_criteria!
    sort!
    paginate!
    @representations
  end

  private
  attr_reader :criteria, :status, :user, :track, :order, :page

  def filter_status!
    # TODO: raise if status is incorrect

    case status
    when :without_feedback
      @representations = @representations.without_feedback
    when :with_feedback
      @representations = @representations.with_feedback
    end
  end

  def filter_user!
    return if user.blank?

    @representations = @representations.where(feedback_author: user).or(@representations.where(feedback_editor: user))
  end

  def filter_track!
    return if track.blank?

    @representations = @representations.where(exercises: { track: })
  end

  def filter_criteria!
    return if criteria.blank?

    @representations = @representations.where('exercises.title LIKE ?', "%#{criteria}%").
      or(@representations.where('exercises.slug LIKE ?', "%#{criteria}%"))
  end

  def sort!
    # TODO: raise if sorting is incorrect

    # TODO: implement
    # case order
    # when :recent
    #   @representations = @representations.order(opened_at: :asc)
    # when :num_occurances
    #   @representations = @representations
    # else
    @representations = @representations.order(id: :asc)
    # end
  end

  def paginate!
    @representations = @representations.page(page).per(self.class.requests_per_page)
  end
end
