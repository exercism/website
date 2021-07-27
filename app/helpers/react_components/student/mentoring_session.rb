module ReactComponents
  module Student
    class MentoringSession < ReactComponent
      initialize_with :solution, :request, :discussion

      def to_s
        super(
          "student-mentoring-session",
          {
            user_handle: student.handle,
            request: SerializeMentorSessionRequest.(request, student),
            discussion: discussion ? SerializeMentorDiscussion.(discussion, student) : nil,
            track: SerializeMentorSessionTrack.(track),
            exercise: SerializeMentorSessionExercise.(exercise),
            iterations: iterations,
            mentor: mentor_data,
            track_objectives: user_track&.objectives.to_s,
            videos: videos,
            links: {
              exercise: Exercism::Routes.track_exercise_mentor_discussions_url(track, exercise),
              create_mentor_request: Exercism::Routes.api_solution_mentor_requests_path(solution.uuid),
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
      def user_track
        UserTrack.for(student, track)
      end

      memoize
      def mentor
        discussion&.mentor
      end

      def mentor_data
        return nil unless mentor

        {
          name: mentor.name,
          handle: mentor.handle,
          bio: mentor.bio,
          languages_spoken: mentor.languages_spoken,
          avatar_url: mentor.avatar_url,
          reputation: mentor.formatted_reputation,
          num_discussions: num_discussions_with_mentor
        }
      end

      def num_discussions_with_mentor
        mentor_relationship = Mentor::StudentRelationship.find_by(mentor: mentor, student: student)
        mentor_relationship&.num_discussions.to_i
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
          unread = discussion ? counts.reject { |(_, seen), _| seen }.present? : false

          SerializeIteration.(iteration).merge(unread: unread)
        end
      end
    end
  end
end
