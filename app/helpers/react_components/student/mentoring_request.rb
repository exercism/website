module ReactComponents
  module Student
    class MentoringRequest < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "student-mentoring-request",
          {
            track: {
              title: track.title,
              median_wait_time: track.median_wait_time
            },
            # TODO
            is_first_time_on_track: true,
            exercise: {
              title: exercise.title
            },
            latest_iteration: SerializeIteration.(solution.latest_iteration),
            request: SerializeMentorRequest.(request),
            videos: videos,
            links: {
              create: Exercism::Routes.api_solution_mentor_request_path(solution.uuid),
              learn_more_about_private_mentoring: "#",
              private_mentoring: "https://some.link/we/need/to-decide-on",
              mentoring_guide: "#"
            }
          }
        )
      end

      private
      delegate :track, :exercise, to: :solution

      def request
        solution.mentor_requests.last
      end

      def videos
        [
          {
            url: "#",
            title: "Start mentoring on Exercism..",
            date: Date.new(2020, 1, 24).iso8601
          },
          {
            url: "#",
            title: "Best practices writing feedback trrrrrruuuuunnnncaaatteeee",
            date: Date.new(2020, 1, 24).iso8601
          },
          {
            url: "#",
            title: "Beginners’ Guide to Mentoring",
            date: Date.new(2020, 1, 24).iso8601
          }
        ]
      end
    end
  end
end
