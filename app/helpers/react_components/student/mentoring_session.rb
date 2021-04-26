module ReactComponents
  module Student
    class MentoringSession < ReactComponent
      initialize_with :solution, :request, :discussion

      def to_s
        super(
          "student-mentoring-session",
          {
            user_id: student.id,
            request: SerializeMentorSessionRequest.(request),
            discussion: discussion ? SerializeMentorDiscussion.(discussion, student) : nil,
            track: SerializeMentorSessionTrack.(track),
            exercise: SerializeMentorSessionExercise.(exercise),
            iterations: iterations,
            mentor: mentor_data,
            is_first_time_on_track: true, # TODO
            videos: videos,
            links: {
              exercise: Exercism::Routes.track_exercise_url(track, exercise),
              create_mentor_request: Exercism::Routes.api_solution_mentor_request_path(solution.uuid),
              learn_more_about_private_mentoring: "#",
              private_mentoring: "https://some.link/we/need/to-decide-on",
              mentoring_guide: "#"
            }
          }
        )
      end

      private
      delegate :track, :exercise, to: :solution

      memoize
      def student
        solution.user
      end

      memoize
      def mentor
        discussion&.mentor
      end

      def mentor_data
        return nil unless mentor

        {
          id: mentor.id,
          name: mentor.name,
          handle: mentor.handle,
          bio: mentor.bio,
          languages_spoken: mentor.languages_spoken,
          avatar_url: mentor.avatar_url,
          reputation: mentor.formatted_reputation,
          num_previous_sessions: student.num_previous_mentor_sessions_with(mentor)
        }
      end

      def videos
        return [] if discussion

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
          comment_counts = discussion.posts.
            group(:iteration_id, :seen_by_student).
            count
        end

        solution.iterations.map do |iteration|
          counts = discussion ? comment_counts.select { |(it_id, _), _| it_id == iteration.id } : nil
          num_comments = discussion ? counts.sum(&:second) : 0
          unread = discussion ? counts.reject { |(_, seen), _| seen }.present? : false

          SerializeIteration.(iteration).merge(num_comments: num_comments, unread: unread)
        end
      end
    end
  end
end
