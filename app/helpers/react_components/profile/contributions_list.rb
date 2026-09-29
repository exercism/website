module ReactComponents
  module Profile
    class ContributionsList < ReactComponent
      initialize_with :user

      def to_s
        super("profile-contributions-list", { categories: })
      end

      private
      # The page shows one list at a time, starting with the first category
      # the user has contributions in. When someone clicks another category's
      # tab, the page fetches that list from its API endpoint.
      #
      # So only the first category needs its list sent with the page. Each
      # category in category_data carries a lambda that builds its first page
      # of results. We call it for the first category and send the result as
      # its initial data. For the other categories we never call it, and send
      # empty options, so the page fetches their lists when their tabs are
      # opened.
      def categories
        shown = category_data.select { |c| c[:count].positive? }

        shown.each_with_index.map do |category, index|
          build_initial_data = category.delete(:initial_data)
          first = index.zero?

          category[:request][:options] = first ? { initial_data: build_initial_data.() } : {}
          category
        end
      end

      def category_data
        [
          {
            title: "Building",
            icon: "building",
            count: User::ReputationToken::Search.(
              @user,
              category: %i[building authoring],
              paginated: false,
              sorted: false
            ).count,
            request: { endpoint: Exercism::Routes.building_api_profile_contributions_url(user.handle) },
            initial_data: lambda {
              SerializePaginatedCollection.(
                User::ReputationToken::Search.(user, category: %i[building authoring]),
                serializer: SerializeUserReputationTokens
              )
            }
          },
          {
            title: "Maintaining",
            icon: "maintaining",
            count: User::ReputationToken::Search.(user, category: :maintaining, paginated: false, sorted: false).count,
            request: { endpoint: Exercism::Routes.maintaining_api_profile_contributions_url(user.handle) },
            initial_data: lambda {
              SerializePaginatedCollection.(
                User::ReputationToken::Search.(user, category: :maintaining),
                serializer: SerializeUserReputationTokens
              )
            }
          },
          {
            title: "Authoring",
            icon: "authoring",
            count: User::RetrieveAuthoredAndContributedExercises.(user, paginated: false, sorted: false).count,
            request: { endpoint: Exercism::Routes.authoring_api_profile_contributions_url(user.handle) },
            initial_data: lambda {
              SerializePaginatedCollection.(
                User::RetrieveAuthoredAndContributedExercises.(user),
                serializer: SerializeExerciseAuthorships
              )
            }
          },
          {
            title: "Other",
            icon: "more-horizontal",
            count: User::ReputationToken::Search.(user, category: :misc, paginated: false, sorted: false).count,
            request: { endpoint: Exercism::Routes.other_api_profile_contributions_url(user.handle) },
            initial_data: lambda {
              SerializePaginatedCollection.(
                User::ReputationToken::Search.(user, category: :misc),
                serializer: SerializeUserReputationTokens
              )
            }
          }
        ]
      end
    end
  end
end
