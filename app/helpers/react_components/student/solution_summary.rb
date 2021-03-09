module ReactComponents
  module Student
    class SolutionSummary < ReactComponent
      initialize_with :solution

      def to_s
        super("student-solution-summary", {
          solution: SerializeSolutionForStudent.(solution),
          discussions: discussions,
          request: request,
          is_concept_exercise: solution.exercise.concept_exercise?,
          links: links
        })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.api_solution_url(solution.uuid, sideload: [:iterations]),
          options: {
            initialData: {
              iterations: solution.
                iterations.
                order(id: :desc).
                map { |iteration| SerializeIteration.(iteration) }
            }
          }
        }
      end

      def links
        {
          tests_passed_locally_article: "#",
          all_iterations: Exercism::Routes.track_exercise_iterations_path(solution.track, solution.exercise),
          community_solutions: "#",
          learn_more_about_mentoring_article: "#",
          mentoring_info: "#",
          complete_exercise: Exercism::Routes.complete_api_solution_url(solution.uuid),
          share_mentoring: "https://some.link/we/need/to-decide-on"
        }
      end

      def discussions
        solution.mentor_discussions.map do |discussion|
          {
            id: discussion.uuid,
            mentor: {
              avatar_url: discussion.mentor.avatar_url,
              handle: discussion.mentor.handle
            },
            is_finished: discussion.finished?,
            is_unread: discussion.posts.where(seen_by_student: false).exists?,
            posts_count: discussion.posts.count,
            created_at: discussion.created_at.iso8601,
            links: {
              self: Exercism::Routes.mentoring_discussion_url(discussion.uuid)
            }
          }
        end
      end
    end
  end
end
