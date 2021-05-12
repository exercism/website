module ReactComponents
  module Student
    class Nudge < ReactComponent
      initialize_with :solution

      def to_s
        super("student-nudge", {
          solution: SerializeSolution.(solution),
          track: {
            title: solution.track.title,
            median_wait_time: solution.track.median_wait_time
          },
          discussions: discussions,
          request: request,
          exercise_type: exercise_type,
          iterations: solution.iterations.map { |iteration| SerializeIteration.(iteration) },
          links: links
        })
      end

      private
      def exercise_type
        return "tutorial" if solution.exercise.tutorial?

        solution.exercise.concept_exercise? ? "concept" : "practice"
      end

      def request
        {
          endpoint: Exercism::Routes.latest_status_api_solution_iterations_url(solution.uuid),
          options: {
            initialData: {
              status: solution.latest_iteration ? solution.latest_iteration.status.to_s : nil
            }
          }.compact
        }
      end

      def links
        {
          mentoring_info: "#",
          complete_exercise: Exercism::Routes.complete_api_solution_url(solution.uuid),
          share_mentoring: "https://some.link/we/need/to-decide-on", # TODO
          request_mentoring: Exercism::Routes.new_track_exercise_mentor_request_path(solution.track, solution.exercise),
          pending_mentor_request: Exercism::Routes.track_exercise_mentor_request_path(solution.track, solution.exercise)
        }.tap do |links|
          in_progress_discussion = solution.mentor_discussions.in_progress_for_student.first
          if in_progress_discussion
            links[:in_progress_discussion] =
              Exercism::Routes.track_exercise_mentor_discussion_path(
                solution.track,
                solution.exercise,
                in_progress_discussion
              )
          end
        end
      end

      def discussions
        SerializeMentorDiscussions.(solution.mentor_discussions, :student)
      end
    end
  end
end
