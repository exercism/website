class User::ReputationToken::Search
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 25

  def self.default_per
    DEFAULT_PER
  end

  def initialize(user, criteria: nil, category: nil, page: nil, per: nil, order: nil,
                 sorted: true, paginated: true)
    @user = user
    @criteria = criteria
    @category = category
    @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
    @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per
    @order = order
    @sorted = sorted
    @paginated = paginated
  end

  def call
    @tokens = user.reputation_tokens.includes(:track, :exercise)

    filter_criteria!
    filter_category!
    sort! if sorted?
    paginate! if paginated?

    @tokens
  end

  private
  attr_reader :user, :criteria, :category,
    :per, :page, :order,
    :tokens

  %i[sorted paginated].each do |attr|
    define_method("#{attr}?") { instance_variable_get("@#{attr}") }
  end

  def filter_criteria!
    return if criteria.blank?

    @tokens = @tokens.joins(:exercise, :track)
    criteria.strip.split(" ").each do |crit|
      @tokens = @tokens.where(
        "exercises.title LIKE ? OR tracks.title LIKE ?",
        "#{crit}%",
        "#{crit}%"
      )
    end
  end

  def filter_category!
    return if category.blank?

    @tokens = @tokens.where(category:)
  end

  def sort!
    case order&.to_sym
    when :unseen_first
      @tokens = @tokens.order(Arel.sql("seen ASC")).order(id: :desc)
    when :oldest_first
      @tokens = @tokens.order(id: :asc)
    else # :newest_first
      @tokens = @tokens.order(id: :desc)
    end
  end

  # Sorting whole rows makes MySQL read every matching token from disk to
  # return one page. The ids are in the index, so we page those and then load
  # only the rows on the page.
  def paginate!
    paged = @tokens.page(page).per(per)
    ids = paged.except(:includes).pluck(:id)
    records = User::ReputationToken.where(id: ids).includes(:track, :exercise).index_by(&:id)

    @tokens = Kaminari.paginate_array(ids.map { |id| records[id] }, total_count: paged.total_count).
      page(page).per(per)
  end
end
