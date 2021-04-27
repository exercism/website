module ReactComponents
  module Mentoring
    class Session < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "mentoring-session",
          {
            user_id: current_user.id,
            relationship: SerializeMentorStudentRelationship.(mentor_student_relationship),
            request: SerializeMentorSessionRequest.(request),
            discussion: discussion ? SerializeMentorDiscussion.(discussion, :mentor) : nil,
            track: SerializeMentorSessionTrack.(track),
            exercise: SerializeMentorSessionExercise.(exercise),
            iterations: iterations,
            student: SerializeStudent.(student, mentor_student_relationship),
            mentor_solution: mentor_solution,
            notes: notes,
            links: links
          }
        )
      end

      memoize
      def request
        ::Mentor::Request.find_by(solution: solution)
      end

      memoize
      def discussion
        ::Mentor::Discussion.find_by(solution: solution, mentor: current_user)
      end

      memoize
      def mentor_student_relationship
        Mentor::StudentRelationship.find_by(mentor: current_user, student: student)
      end

      def links
        {
          mentor_dashboard: Exercism::Routes.mentoring_inbox_path,
          exercise: Exercism::Routes.track_exercise_path(track, exercise),
          scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
        }
      end

      def iterations
        if discussion
          comment_counts = ::Mentor::DiscussionPost.
            where(discussion: discussion).
            group(:iteration_id, :seen_by_mentor).
            count
        end

        solution.iterations.map do |iteration|
          counts = discussion ? comment_counts.select { |(it_id, _), _| it_id == iteration.id } : nil
          num_comments = discussion ? counts.sum(&:second) : 0
          unread = discussion ? counts.reject { |(_, seen), _| seen }.present? : 0

          SerializeIteration.(iteration).merge(num_comments: num_comments, unread: unread)
        end
      end

      def mentor_solution
        ms = ::Solution.for(current_user, exercise)
        ms ? SerializeCommunitySolution.(ms) : nil
      end

      # TODO
      def notes
        markdown = Git::WebsiteCopy.new.mentor_notes_for(track.slug, exercise.slug).strip
        Markdown::Parse.(markdown)
      end

      memoize
      delegate :exercise, :track, to: :solution

      def student
        solution.user
      end

      memoize
      def scratchpad
        ScratchpadPage.new(about: exercise)
      end
    end
  end
end
