module ReactComponents
  module Profile
    class ContributionsList < ReactComponent
      initialize_with :user

      def to_s
        super("profile-contributions-list", { categories: })
      end

      private
      def categories
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
            request: {
              endpoint: Exercism::Routes.building_api_profile_contributions_url(user.handle),
              options: {
                initial_data: SerializePaginatedCollection.(
                  User::ReputationToken::Search.(user, category: %i[building authoring]),
                  serializer: SerializeUserReputationTokens
                )
              }
            }
          },
          {
            title: "Maintaining",
            icon: "maintaining",
            count: User::ReputationToken::Search.(user, category: :maintaining, paginated: false, sorted: false).count,
            request: {
              endpoint: Exercism::Routes.maintaining_api_profile_contributions_url(user.handle),
              options: {
                initial_data: SerializePaginatedCollection.(
                  User::ReputationToken::Search.(user, category: :maintaining),
                  serializer: SerializeUserReputationTokens
                )
              }
            }
          },
          {
            title: "Authoring",
            icon: "authoring",
            count: User::RetrieveAuthoredAndContributedExercises.(user, paginated: false, sorted: false).count,
            request: {
              endpoint: Exercism::Routes.authoring_api_profile_contributions_url(user.handle),
              options: {
                initial_data: SerializePaginatedCollection.(
                  User::RetrieveAuthoredAndContributedExercises.(user),
                  serializer: SerializeExerciseAuthorships
                )
              }
            }
          },
          {
            title: "Other",
            icon: "more-horizontal",
            count: User::ReputationToken::Search.(user, category: :misc, paginated: false, sorted: false).count,
            request: {
              endpoint: Exercism::Routes.other_api_profile_contributions_url(user.handle),
              options: {
                initial_data: SerializePaginatedCollection.(
                  User::ReputationToken::Search.(user, category: :misc),
                  serializer: SerializeUserReputationTokens
                )
              }
            }
          }
        ].select { |c| c[:count].positive? }
      end
    end
  end
end
