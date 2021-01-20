class User
  class ReputationToken
    class Search
      include Mandate

      def initialize(user, criteria: nil, category: nil)
        @user = user
        @criteria = criteria
        @category = category
      end

      def call
        @tokens = user.reputation_tokens
        filter_criteria
        filter_category
        @tokens
      end

      private
      attr_reader :user, :criteria, :category,
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
    end
  end
end
