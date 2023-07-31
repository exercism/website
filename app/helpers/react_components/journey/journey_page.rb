module ReactComponents
  module Journey
    class JourneyPage < ReactComponent
      initialize_with :default_category_id, :params

      def to_s
        super("journey-journey-page", {
          categories:,
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
                sync_status: params[:sync_status],
                tests_status: params[:tests_status],
                head_tests_status: params[:head_tests_status],
                page: params[:page],
                order: params[:order] || :newest_first
              ),
              serializer: SerializeSolutions,
              serializer_args: [current_user]
            )
          }
          query = {
            criteria: params[:criteria],
            track_slug: params[:track_id],
            status: params[:status],
            mentoring_status: params[:mentoring_status],
            sync_status: params[:sync_status],
            tests_status: params[:tests_status],
            head_tests_status: params[:head_tests_status],
            page: params[:page],
            order: params[:order] || :newest_first
          }.compact
        else
          options = {}
          query = {}
        end

        {
          id: "solutions",
          title: "Solutions",
          request: {
            endpoint: Exercism::Routes.api_solutions_url,
            query:,
            options:
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
          query = params.slice(*AssembleReputationTokens.keys)
        else
          options = {}
          query = {}
        end

        {
          id: "reputation",
          title: "Reputation",
          request: {
            endpoint: Exercism::Routes.api_reputation_index_url,
            query:,
            options:
          },
          path: Exercism::Routes.reputation_journey_path,
          icon: "reputation"
        }
      end

      def overview_category
        if default_category_id == "overview"
          options = {
            initial_data: AssembleJourneyOverview.(current_user)
          }
        else
          options = {}
        end

        {
          id: "overview",
          title: "Overview",
          request: {
            endpoint: Exercism::Routes.api_journey_overview_url,
            query: {},
            options:
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
          query = {
            order: params[:order],
            criteria: params[:criteria]
          }.compact
        else
          options = {}
          query = {}
        end

        {
          id: "badges",
          title: "Badges",
          request: {
            endpoint: Exercism::Routes.api_badges_url,
            query:,
            options:
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
