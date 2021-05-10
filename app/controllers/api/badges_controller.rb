module API
  class BadgesController < BaseController
    def index
      badges = User::AcquiredBadge::Search.(
        current_user,
        criteria: params[:criteria],
        category: params[:category],
        order: params[:order],
        per: params[:per_page],
        page: params[:page]
      )

      render json: SerializePaginatedCollection.(
        badges,
        serializer: SerializeUserAcquiredBadges
      )
    end
  end
end
