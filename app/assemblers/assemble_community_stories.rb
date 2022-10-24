class AssembleCommunityStories
  include Mandate

  initialize_with :params

  def call
    SerializePaginatedCollection.(
      stories,
      serializer: SerializeCommunityStories,
      meta: {
        unscoped_total: stories_count
      }
    )
  end

  private
  def stories = CommunityStory::Search.(exclude_ids:, per: 12, page: params[:page])
  def stories_count = CommunityStory::Search.(exclude_ids:, paginated: false).count

  def exclude_ids
    return unless params[:id].present?

    [params[:id]]
  end
end
