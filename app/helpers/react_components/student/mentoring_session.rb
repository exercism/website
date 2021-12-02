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
            discussion: discussion ? SerializeMentorDiscussionForStudent.(discussion) : nil,
            track: SerializeMentorSessionTrack.(track),
            exercise: SerializeMentorSessionExercise.(exercise),
            iterations: iterations,
            mentor: mentor_data,
            track_objectives: user_track&.objectives.to_s,
            out_of_date: solution.out_of_date?,
            videos: videos,
            links: {
              exercise: Exercism::Routes.track_exercise_mentor_discussions_url(track, exercise),
              create_mentor_request: Exercism::Routes.api_solution_mentor_requests_path(solution.uuid),
              learn_more_about_private_mentoring: Exercism::Routes.doc_path(:using, "feedback/private"),
              private_mentoring: solution.external_mentoring_request_url,
              mentoring_guide: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored")
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
            url: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored"),
            thumb: "https://exercism-static.s3.eu-west-1.amazonaws.com/blog/tutorial-making-the-most-of-being-mentored.png",
            title: "Making the most of being mentored",
            date: Date.new(2021, 9, 1).iso8601
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
