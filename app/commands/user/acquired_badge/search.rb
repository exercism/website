class User::AcquiredBadge::Search
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 25

  def self.default_per
    DEFAULT_PER
  end

  def initialize(user, criteria: nil, category: nil, page: nil, per: nil, order: nil)
    @user = user
    @criteria = criteria
    @category = category
    @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
    @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per
    @order = order
  end

  def call
    @badges = user.acquired_badges

    filter_criteria!
    sort!
    paginate!

    @badges
  end

  private
  attr_reader :user, :criteria, :category,
    :per, :page, :order,
    :badges

  def filter_criteria!
    return if criteria.blank?

    @badges = @badges.joins(:badge).where("badges.name LIKE ?", "#{criteria}%")
  end

  def sort!
    case order&.to_sym
    when :unrevealed_first
      @badges = @badges.order(Arel.sql("revealed ASC")).order(id: :desc)
    when :oldest_first
      @badges = @badges.order(:id)
    else # :newest_first
      @badges = @badges.order(id: :desc)
    end
  end

  def paginate!
    @badges = @badges.page(page).per(per)
  end
end
