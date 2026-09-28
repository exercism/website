module ReactComponents
  module Profile
    class ContributionsList < ReactComponent
      initialize_with :user

      def to_s
        super("profile-contributions-list", { categories: })
      end

      private
      def categories
        category_data.select { |c| c[:count].positive? }.each_with_index.map do |category, idx|
          initial_data = category.delete(:initial_data)
          category[:request][:options] = idx.zero? ? { initial_data: initial_data.() } : {}
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
