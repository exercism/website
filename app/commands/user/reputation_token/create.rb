class User
  class ReputationToken
    class Create
      include Mandate

      def initialize(user, context_key, category, reason,
                     context: nil, external_link: nil,
                     track: nil, exercise: nil)
        @user = user
        @context_key = context_key
        @reason = reason
        @category = category
        @context = context
        @external_link = external_link
        @track = track
        @exercise = exercise
      end

      def call
        User::ReputationToken.create_or_find_by!(
          user: user,
          context_key: context_key
        ) do |token|
          token.context = context
          token.reason = reason
          token.category = category
          token.context = context
          token.external_link = external_link
          token.exercise = exercise
          token.track = track
        end
      end

      private
      attr_reader :user, :context_key, :reason, :category,
        :context, :external_link,
        :track, :exercise
    end
  end
end
