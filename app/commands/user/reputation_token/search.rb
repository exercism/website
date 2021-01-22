class User
  class ReputationToken
    class Search
      include Mandate

      DEFAULT_PAGE = 1
      DEFAULT_PER = 25

      def initialize(user, criteria: nil, category: nil, page: nil, per: nil, order: nil)
        @user = user
        @criteria = criteria
        @category = category
        @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE # rubocop:disable Style/ConditionalAssignment
        @per = per.present? && per.to_i.positive? ? per.to_i : DEFAULT_PER # rubocop:disable Style/ConditionalAssignment
        @order = order
      end

      def call
        @tokens = user.reputation_tokens

        filter_criteria
        filter_category
        sort

        @tokens.page(page).per(per)
      end

      private
      attr_reader :user, :criteria, :category,
        :per, :page, :order,
        :tokens

      def filter_criteria
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

      def filter_category
        return if category.blank?

        @tokens = @tokens.where(category: category)
      end

      def sort
        case order&.to_sym
        when :oldest_first
          @tokens = @tokens.order(id: :asc)
        else # :newest_first
          @tokens = @tokens.order(id: :desc)
        end
      end
    end
  end
end
