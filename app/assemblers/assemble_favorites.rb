class AssembleFavorites
  include Mandate

  initialize_with :user, :params

  def self.keys
    %i[criteria order track_slug page]
  end

  def call
    SerializePaginatedCollection.(
      solutions,
      serializer: SerializeCommunitySolutions,
      meta: {
        unscoped_total: user.solution_stars.count
      }
    )
  end

  memoize
  def solutions
    Solution::SearchFavorites.(
      user,
      criteria: params[:criteria],
      track_slug: params[:track_slug],
      # order: params[:order],
      page: params[:page]
    )
  end
end
