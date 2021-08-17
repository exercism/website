module ReactComponents
  module Journey
    class JourneyPage < ReactComponent
      initialize_with :default_category_id, :params

      def to_s
        super("journey-journey-page", {
          categories: categories,
          default_category: default_category_id
        })
      end

      private
      def solution_category
        if default_category_id == "solutions"
          options = {
            initial_data: SerializePaginatedCollection.(
              Solution::SearchUserSolutions.(
                current_user,
                criteria: params[:criteria],
                track_slug: params[:track_id],
                status: params[:status],
                mentoring_status: params[:mentoring_status],
                page: params[:page],
                order: params[:order]
              ),
              serializer: SerializeSolutions,
              serializer_args: [current_user]
            )
          }
        else
          options = {}
        end

        {
          id: "solutions",
          title: "Solutions",
          request: {
            endpoint: Exercism::Routes.api_solutions_url,
            query: {
              criteria: params[:criteria],
              track_slug: params[:track_id],
              status: params[:status],
              mentoring_status: params[:mentoring_status],
              page: params[:page],
              order: params[:order]
            }.compact,
            options: options
          },
          path: Exercism::Routes.solutions_journey_path,
          icon: "editor"
        }
      end

      def reputation_category
        if default_category_id == "reputation"
          options = {
            initial_data: AssembleReputationTokens.(current_user, params)
          }
        else
          options = {}
        end

        {
          id: "reputation",
          title: "Reputation",
          request: {
            endpoint: Exercism::Routes.api_reputation_index_url,
            query: params.slice(*AssembleReputationTokens.keys),
            options: options
          },
          path: Exercism::Routes.reputation_journey_path,
          icon: "reputation"
        }
      end

      def overview_category
        {
          id: "overview",
          title: "Overview",
          request: {
            endpoint: Exercism::Routes.api_journey_overview_url,
            query: {},
            options: {
              initial_data: AssembleJourneyOverview.(current_user)
            }
          },
          path: Exercism::Routes.journey_path,
          icon: "overview"
        }
      end

      def badges_category
        if default_category_id == "badges"
          options = {
            initial_data: SerializePaginatedCollection.(
              User::AcquiredBadge::Search.(
                current_user,
                order: params[:order],
                criteria: params[:criteria]
              ),
              serializer: SerializeUserAcquiredBadges
            )
          }
        else
          options = {}
        end

        {
          id: "badges",
          title: "Badges",
          request: {
            endpoint: Exercism::Routes.api_badges_url,
            query: {
              order: params[:order],
              criteria: params[:criteria]
            }.compact,
            options: options
          },
          path: Exercism::Routes.badges_journey_path,
          icon: "badges"
        }
      end

      def categories
        [overview_category, solution_category, reputation_category, badges_category]
      end
    end
  end
end
