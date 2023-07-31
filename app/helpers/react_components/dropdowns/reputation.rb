module ReactComponents
  module Dropdowns
    class Reputation < ReactComponent
      initialize_with :user

      def to_s
        super(
          "dropdowns-reputation",
          {
            reputation: user.formatted_reputation,
            is_seen: !user.has_unseen_reputation_tokens?,
            endpoint: Exercism::Routes.api_reputation_index_url(for_header: true)
          }
        )
      end
    end
  end
end
