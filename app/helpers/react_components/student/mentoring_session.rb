module ReactComponents
  module Student
    class MentoringSession < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "student-mentoring-session",
          {
            user_id: current_user.id,
            discussion: SerializeMentorDiscussion.(discussion, current_user),
            iterations: iterations,
            track: {
              title: track.title,
              highlightjs_language: track.highlightjs_language,
              median_wait_time: track.median_wait_time,
              icon_url: track.icon_url
            },
            exercise: {
              title: exercise.title,
              icon_name: exercise.icon_name
            },
            is_first_time_on_track: true, # TODO
            videos: videos,
            request: SerializeMentorRequest.(request),
            links: {
              exercise: Exercism::Routes.track_exercise_url(track, exercise),
              create_request: Exercism::Routes.api_solution_mentor_request_path(solution.uuid),
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

      def discussion
        solution.mentor_discussions.last
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

      def iterations
        if discussion
          comment_counts = ::Solution::MentorDiscussionPost.
            where(discussion: discussion).
            group(:iteration_id, :seen_by_student).
            count
        end

        solution.iterations.map do |iteration|
          counts = discussion ? comment_counts.select { |(it_id, _), _| it_id == iteration.id } : nil
          num_comments = discussion ? counts.sum(&:second) : 0
          unread = discussion ? counts.reject { |(_, seen), _| seen }.present? : 0

          SerializeIteration.(iteration).merge(num_comments: num_comments, unread: unread)
        end
      end
    end
  end
end
