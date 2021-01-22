module API
  class ReputationController < BaseController
    def self.per
      25
    end

    def index
      tokens = User::ReputationToken::Search.(
        current_user,
        criteria: params[:criteria],
        category: params[:category]
      )

      tokens = tokens.page(params[:page] || 1).per(params[:per] || self.class.per)

      case params[:sort]
      when "oldest_first"
        tokens = tokens.order(:created_at)
      when "newest_first"
        tokens = tokens.order(created_at: :desc)
      end

      render json: SerializePaginatedCollection.(tokens, SerializeReputationToken)
    end
  end
end
