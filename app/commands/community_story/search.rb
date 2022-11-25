class CommunityStory::Search
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 25

  initialize_with exclude_ids: [], page: DEFAULT_PAGE, per: DEFAULT_PER, paginated: true

  def call
    @stories = CommunityStory.published

    filter_exclude_ids!
    sort!
    paginate! if paginated
    @stories
  end

  private
  attr_reader :stories

  def filter_exclude_ids!
    return if exclude_ids.blank?

    @stories = @stories.where.not(id: exclude_ids)
  end

  def sort!
    @stories = @stories.ordered_by_recency
  end

  def paginate!
    @stories = @stories.page(page).per(per)
  end
end
